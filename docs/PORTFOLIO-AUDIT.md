# Portfolio Audit — `joshua1571/nix-config`

**Reviewer framing:** technical screen for an infrastructure / platform / systems
engineering role at a large defense contractor. The repo is treated as the
candidate's primary work sample. Reviewed at commit `b4941ce` (2026-08-06).

**Bottom line:** advance to interview. This is a genuine multi-host
infrastructure-as-code estate, not a dotfiles repo, and the reasoning quality in
the hard parts (policy routing, systemd ordering, ZFS mount races) is well above
what a homelab portfolio normally shows. It is held back by a set of hygiene and
posture problems that a reviewer will find in the first fifteen minutes: CI has
been red on `main` for six consecutive pushes, the host firewall is globally
disabled while the documentation claims network-level access control, and there
is no README. Those are all cheap to fix and they are the difference between
"interesting" and "hire".

---

## 1. Scorecard

| Dimension | Score | Note |
|---|---|---|
| Systems depth | 8/10 | WireGuard policy routing, nftables marking, ZFS/systemd ordering — real and correctly reasoned |
| Declarative / IaC discipline | 8/10 | Flakes, pinned inputs, agenix, per-host composition. Idiomatic Nix |
| Documentation | 6/10 | Excellent per-host SPECs; no top-level README; `CLAUDE.md` describes a design that was deleted |
| Security posture | 4/10 | Firewall off estate-wide, unauthenticated LLM UI on LAN, over-broad NOPASSWD sudo rule |
| Testing / verification | 3/10 | CI evaluates but never builds; no VM tests; CI red for a month |
| Operational maturity | 3/10 | No backups, no monitoring, no alerting on ZFS or SMART, no restore procedure |
| Repo hygiene | 5/10 | Red CI on main, formatting failures, orphaned modules, `settings.local.json` committed |
| Commit / process discipline | 5/10 | "Fixes", "Minor fixes", "Intermediate troubleshooting commit"; direct pushes to red main |

**Read as a level signal:** the systems reasoning reads mid-to-senior. The
operational and verification discipline reads junior. In a cleared program
environment, the second half is what gets audited, and it is the half that is
weak. Closing that gap is the highest-leverage thing on this list.

---

## 2. What lands well

These are the things worth leading with in an interview — they are specific,
verifiable, and hard to fake.

**Selective VPN egress with policy routing** (`modules/nixos/mullvad.nix`,
`modules/nixos/qbittorrent.nix`). One application's traffic is marked by UID in
an nftables `route`-hook chain, steered into a dedicated routing table, and
egressed through a WireGuard interface that deliberately installs *no* default
route in the main table. The peer is configured imperatively in `postSetup`
specifically to stop the NixOS module from generating `allowedIPs` routes in the
main table. The comments explain *why* systemd-resolved is exempt from the kill
switch and how the DNS host route threads the needle. This is the single
strongest artifact in the repo. Most candidates reach for a container or a
network namespace here; the fwmark approach is more precise and shows the
candidate understands the Linux routing stack rather than a wrapper around it.

**Mount-ordering correctness** (`hosts/server/storage.nix`,
`modules/nixos/nextcloud.nix`). Both modules document and work around the same
class of bug: `systemd-tmpfiles` runs at `sysinit.target`, before
`zfs-mount.service`, so rules targeting paths under a ZFS mountpoint land on the
underlying directory and get shadowed. The fix — a oneshot with
`RequiresMountsFor`, ordered `after = [ "zfs-mount.service" ]` — is correct, and
the Nextcloud module goes further by re-running `systemd-tmpfiles --create
--prefix=` post-mount to recreate the `override.config.php` symlink. Diagnosing
that failure mode requires actually reading unit ordering, not guessing.

**Per-host SPEC.md as intent documentation** (`hosts/*/SPEC.md`). Separating
"what this machine should do" from "how the modules implement it", with an
explicit *Known gaps / TODO* section per host, is a discipline most senior
engineers don't maintain. The gap sections are honest — `laptop/SPEC.md` admits
missing hardware model numbers rather than papering over them. This maps
directly onto how requirements traceability works in a defense program, and it
is the artifact to point at when asked "how do you hand a system off?"

**Secrets handled properly at rest** (`secrets.nix`, `modules/nixos/agenix.nix`).
Age-encrypted secrets keyed to host SSH keys, decrypted at boot, referenced by
path rather than by value, with correct `owner`/`mode`. The Nextcloud
trusted-domain unit uses systemd `LoadCredential` to hand a root-owned secret to
a non-root service instead of loosening the file mode — that is the right
instinct.

**Nontrivial CI exists at all.** Evaluation, formatting, linting, and dead-code
detection on every push and PR. Most homelab repos have nothing.

---

## 3. Findings

Severity is judged against the standard a reviewer applies to a work sample: how
badly does this contradict the repo's own claims, and would it survive a
security review in a regulated environment.

### Critical

**C1 — The firewall is disabled estate-wide, which makes most of the documented
network posture false.**
`modules/nixos/common.nix:130` sets `networking.firewall.enable = false;`, and
every host imports `common.nix`. Every `openFirewall = true` in the service
modules and every `networking.firewall.interfaces.tailscale0.allowedTCPPorts`
rule is therefore inert.

The consequence is that these claims are not true as configured:

- `modules/nixos/nginx.nix:146` — "Expose HTTPS on the tailscale interface only."
  The catch-all `server_name _` vhost, which reverse-proxies Radarr, Sonarr,
  Lidarr, Prowlarr and the qBittorrent WebUI, is reachable from the LAN.
- `modules/nixos/qbittorrent.nix:9` — "Safe because the WebUI only listens on
  tailscale." It listens on `0.0.0.0:8080` and is LAN-reachable.
- `hosts/server/SPEC.md` — "Tailscale-only TCP ports: 443 (nginx), 8080
  (qBittorrent web UI)". Neither is Tailscale-only.
- `CLAUDE.md` — "exposed only on `tailscale0:443`". Same.

The most important thing here is not the LAN exposure itself — it is that the
repo asserts a control it does not implement, in four places, in comments written
with confidence. In a program environment that is a finding against the
documentation, not just the config. A reviewer who spots this will assume other
security comments are also aspirational.

*Fix:* enable the firewall and let the per-service `openFirewall` and
`interfaces.tailscale0` rules do their job — they are already written correctly
and would work the moment the global switch flips. Do this on one host first
(see C2 before doing it at all). Then re-verify each claim with `ss -tlnp` and
`nft list ruleset` from an off-tailnet LAN host, and correct the comments to
describe what is actually enforced.

**C2 — Enabling the firewall as-is will lock you out of SSH.**
`modules/nixos/openssh_server.nix` sets the port via `settings.Port = "2228"`,
but `openFirewall = true` opens `services.openssh.ports`, which is still at its
default `[ 22 ]`. The firewall rule and the daemon configuration are derived
from two different sources of truth. Today this is invisible because the
firewall is off; the moment C1 is fixed, the open port and the listening port
disagree. Depending on the module version sshd may also still be binding 22
alongside 2228 — worth confirming with `ss -tlnp | grep sshd` before changing
anything.

*Fix:* `services.openssh.ports = [ 2228 ];` and drop `settings.Port`. Verify
with `nixos-rebuild test` and a second session open before switching. Sequence
C2 before C1.

**C3 — The `jrhassistant` NOPASSWD sudo rule is equivalent to passwordless
root.**
`modules/nixos/common.nix:35` grants `NOPASSWD` on
`/run/current-system/sw/bin/nix*`. Sudo command specifications with no argument
list permit *any* arguments, so this authorizes `sudo nix run nixpkgs#…`,
`sudo nix-shell --run …`, and `sudo nix build --impure` with arbitrary
expressions — arbitrary code execution as root, without a password, from an
account whose only credential is an SSH key. The account is also in `wheel`, and
the rule is in `common.nix`, so it exists on all four hosts including the one
holding the household's photos and documents.

This is a defensible tradeoff for an automation account on a personal network,
and the intent (let an agent rebuild and reboot) is clear. But it is presented
without a stated threat model, and the wildcard is almost certainly broader than
intended. In a review setting the question is not "is this exploitable" but "did
the author know how wide it was".

*Fix:* narrow to the specific invocation needed — a wrapper script with a fixed
argv, or `/run/current-system/sw/bin/nixos-rebuild switch --flake /path/to/config#hostname`
with no wildcard — and drop `jrhassistant` from `wheel` if the NOPASSWD rules
cover its actual job. Note in a comment what the account is for and what it is
trusted to do. Related: `nix.settings.trusted-users = [ "@wheel" ]`
(`common.nix:52`) grants daemon-level trust that is also root-equivalent in
practice; worth an explicit comment acknowledging it.

**C4 — Unauthenticated LLM web UI and API on the desktop, LAN-reachable.**
`modules/nixos/local_ai_server.nix:27` sets `WEBUI_AUTH = "False"` on Open WebUI
(port 8080), and line 13 binds Ollama to `0.0.0.0:11434`. With C1 in place,
both are reachable from any device on the LAN with no credential. Anyone on the
network can query the model, read chat history, and — depending on the enabled
Open WebUI features — pull files the service can read.

*Fix:* bind Open WebUI and Ollama to `127.0.0.1`, or leave them bound wide and
gate on the firewall once C1 lands. Turn `WEBUI_AUTH` back on. If the intent is
"reachable from the laptop over Tailscale", express that as
`networking.firewall.interfaces.tailscale0.allowedTCPPorts` rather than by
disabling authentication.

### High

**H1 — CI has been failing on `main` for six consecutive pushes, spanning five
weeks (2026-07-31 through 2026-08-06).**
The failing step is `nixfmt --check`, on five files: `modules/nixos/navidrome.nix`,
`modules/home-manager/kde_packages.nix`, `hosts/desktop/default.nix`,
`hosts/laptop/default.nix`, `users/jrh/home/server.nix` — all tab-indented lines
that the formatter rejects.

For a hiring reviewer this is the single most damaging item in the repo, and it
is more damaging than the security findings. It is a five-minute fix that has
been red for a month, on a repo whose entire value proposition is discipline and
reproducibility. A reviewer reads a red badge on `main` as "CI is decorative
here", and then discounts everything CI would otherwise have vouched for.

*Fix:* run `just fmt` — actually, note that the `fmt` recipe only *checks*;
`just fmt-file <file>` formats one file, and there is no recipe that formats
the tree. Add one. Then either enable branch protection on `main` requiring the
check, or accept that CI is advisory and say so. Do not leave it red.

**H2 — The kill switch has a leak path when the tunnel drops.**
`modules/nixos/qbittorrent.nix:54` accepts all `ct state established,related`
traffic from the qBittorrent UID. The stated purpose is to let WebUI responses
out over LAN/Tailscale, which is correct. But it also matches already-established
*torrent* flows. When `mullvad0` goes down, the kernel removes the
`default dev mullvad0 table 200` route, marked packets for existing connections
fall through to the main routing table, egress via the physical NIC — and this
rule accepts them, because conntrack still considers them established. Only
*new* connections are blocked.

This is a subtle bug and finding it is a point in the candidate's favor, not
against — but it means the kill switch does not do the one thing it exists to do
under exactly the condition it was written for.

*Fix:* scope the established accept so it cannot match tunnel traffic — match on
`ct mark != 0x200`, or restrict it to the WebUI (`tcp sport 8080`) and the
interfaces it should egress on. Then test it: `ip link set mullvad0 down` with
an active torrent, and watch for outbound packets from the qBittorrent UID on
the physical interface. Being able to describe that test in an interview is
worth more than the fix.

**H3 — No backups, despite the datasets existing.**
`tank/backups/{desktop,laptop,macbookpro}` are provisioned in
`hosts/server/storage.nix` but nothing writes to them, nothing pulls from the
clients, there is no retention policy, no offsite copy, and no restore
procedure. `services.zfs.autoSnapshot` is on, which protects against deletion
but not against pool loss, fire, or theft. `server/SPEC.md` honestly lists this
as a gap, which is to the author's credit, but it has been a gap for the life of
the repo.

For a defense-adjacent role this is the most consequential *operational* gap on
the list. Availability and recoverability are graded requirements, not
nice-to-haves, and "I built a media stack" reads very differently from "I built
a media stack with a tested restore path".

*Fix:* the smallest credible version is `services.sanoid`/`syncoid` for
snapshot management plus `services.restic.backups` pushing `tank/personal` to
one off-site target with a password from agenix. Then — and this is the part
that matters — perform one restore, and write down what it took and how long in
`hosts/server/SPEC.md`.

**H4 — No alerting on the things most likely to fail silently.**
`autoScrub` is enabled but ZED is not configured to notify
(`services.zfs.zed.settings`), and `smartmontools` is installed but `smartd` is
not enabled. A degraded pool or a failing disk produces no signal. There is no
node exporter, no uptime check, no notification path of any kind on any host —
the only observability is a dashboard that has to be looked at.

*Fix:* enable `services.smartd` with a notification target, set
`services.zfs.zed.settings.ZED_EMAIL_ADDR`, and pick one delivery mechanism
(email via an agenix-stored app password, or an ntfy/Pushover token). One
alerting path that works beats a metrics stack that nobody watches.

### Medium

**M1 — `CLAUDE.md` documents an architecture that was deleted.** It describes
`specialArgs` feature flags (`desktop-environment`, `game-streaming-client`,
`game-streaming-server`, `emulation`) and `lib.optionals desktop-environment`
composition — all removed in `003890c` (2026-05-05). It also lists `just gc`,
`just clean`, and `just repl`, none of which exist; the actual recipes are
`gc-system`, `gc-home`, `clean-system`, `clean-home`, and there is no `repl`. A
stale architecture doc is worse than no doc, because a reader trusts it.

**M2 — No top-level `README.md`.** `hosts/README.md` exists and is good, but the
repository root has nothing. A reviewer landing on the GitHub page sees a file
tree and `CLAUDE.md`. This is the highest ratio of impact to effort in the entire
audit: four hosts, a topology sketch, the bootstrap procedure, and a paragraph on
the qBittorrent VPN routing design would change the first impression completely.
There is also no `LICENSE`.

**M3 — Cross-module secret coupling.** `modules/nixos/homepage-dashboard.nix:49`
reads `config.age.secrets.nextcloud-adminpass.path`, but that secret is declared
in `nextcloud.nix`. The dashboard module fails to evaluate on any host that
doesn't also import Nextcloud. Each module should declare the secrets it
consumes.

**M4 — Secret written world-readable before being locked down.**
`homepage-dashboard.nix:54-55` redirects into `/run/homepage-env` (created 0644
under the default umask) and *then* `chmod 400`. There is a window where every
API key and the Nextcloud admin password are world-readable. Use `umask 077` at
the top of the script, or `install -m 0400 /dev/null` first, or move to a
`RuntimeDirectory` with an explicit mode. Also note `$(cat …)` fails silently
into an empty value if a secret is missing — `set -euo pipefail` would surface it.

**M5 — Samba host ACL is broader than intended.**
`modules/nixos/smb_share_server.nix:15` — `"hosts allow" = "10.0.0. 100. 127.0.0.1"`.
The `100.` entry is presumably meant to be the Tailscale CGNAT range
(`100.64.0.0/10`) but as written it matches all of `100.0.0.0/8`, which includes
routable public space. Write it as `100.64.0.0/10`. Separately, the client
credentials file (`smb_share_client.nix:27`) lives at
`/home/${username}/.samba/credentials` in plaintext, is not managed by this
flake, and is not documented anywhere — a rebuild on a fresh machine silently
produces a broken mount.

**M6 — Orphaned and duplicated modules.** `modules/nixos/docker.nix`,
`home-assistant.nix`, and `syncthing.nix` are imported by no host.
`modules/home-manager/neovim.nix` is dead alongside the live nixvim config.
`game-streaming-client.nix` and `game-streaming-server.nix` are byte-identical —
both enable Sunshine (the *server*); the client should be Moonlight — and neither
is imported, while `desktop/SPEC.md` claims game streaming as desired
functionality. `deadnix` is in CI but only catches unused *bindings*, not unused
files. Delete or wire up.

**M7 — Literal `$username` in an environment variable.**
`modules/nixos/local_ai_server.nix:18` — `OLLAMA_HOME = "/home/$username/.ollama"`.
Nix interpolation is `${…}`; this passes the literal string `$username` to
systemd, which does not expand it either. The module also doesn't take
`username` as an argument. Ollama is writing to a directory literally named
`$username`.

**M8 — Four near-identical `nixosConfigurations` blocks.** `flake.nix` repeats the
same 25-line `let … in nixpkgs.lib.nixosSystem { … }` structure four times,
differing only in hostname, nixpkgs channel, and home-manager entry point. A
`mkHost` helper would cut it to four call sites and make the stable/unstable
split explicit rather than implicit in which input name is spelled. This is the
kind of thing a reviewer flags as "can they see the abstraction" — and it is
visible in the file most likely to be opened first.

### Low

**L1 — CI is not reproducible and does not build anything.** `nix flake check
--no-build` evaluates but never realizes a derivation, so a config that evaluates
cleanly and fails to build passes CI. The formatting, lint, and dead-code steps
invoke `nix shell nixpkgs#nixfmt` / `nix run nixpkgs#statix`, which resolve
through the *registry*, not `flake.lock` — the pinned repo checks itself with
unpinned tools. Add `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`
for at least one host, source the tools from `flake.lock`, and add a `formatter`
output so `nix fmt` works.

**L2 — `.claude/settings.local.json` is committed.** `*.local.*` settings are
conventionally gitignored. This one carries an allowlist including
`Read(//root/**)`, `Bash(ssh *)`, and `Bash(sudo journalctl *)`, plus internal
store paths and filesystem layout. Not a vulnerability; it is the kind of
incidental disclosure that a security-conscious reviewer notices.

**L3 — Personal information published in a public repo.**
`modules/nixos/homepage-dashboard.nix:94-95` hardcodes coordinates
(33.6439, -117.7481 — resolves to a specific city), line 137 embeds a personal
Feedly account UUID, and the Administration section enumerates the internal
network: router at 10.0.0.1, switch at 10.0.0.2, KVM at 10.0.0.209, Home
Assistant at 10.0.0.155. Meanwhile the *Tailscale hostname* is encrypted with
agenix. That inversion is the actual finding — a reviewer will ask what threat
model puts a tailnet name in a vault and home coordinates in plaintext, and the
honest answer is that there isn't one. Pick a consistent line and apply it.
For anyone whose career path runs through a cleared environment, minimizing
public personal-attack surface is worth doing on its own merits.

**L4 — Commit and branch hygiene.** "Fixes", "Minor fixes", "Intermediate
troubleshooting commit", and several `Merge branch 'main' of github.com:…`
commits from unrebased pulls. Pushes go directly to `main`, including the six
that left CI red. There is no branch protection and no `CODEOWNERS`. The
earlier PR-based work (#1–#5) shows the candidate *can* work through PRs — the
practice just lapsed.

**L5 — Stable channel is drifting.** `nixpkgs` (stable, serving the host with all
the data on it) is pinned to 2026-06-30 — about five weeks stale at time of
review — and there is no scheduled update. A weekly `nix flake update` workflow
opening a PR, gated on the CI that already exists, closes this and demonstrates
supply-chain awareness.

**L6 — `X11Forwarding = true`** on all four hosts, including the headless server,
where it is unused attack surface.

**L7 — Justfile/CLAUDE.md ergonomics.** `build-htpc` hardcodes
`jrhassistant@htpc` and port 2228, `colmena` is declared as a flake input but
unused (it pulls transitive inputs into the lock for nothing), and the "TODO Low
Priority" block in `flake.nix` has been static since March.

---

## 4. What a defense-contractor panel will ask about — and what's missing

The homelab domain (media, torrents, game streaming) is not a problem in itself;
interviewers care about the engineering, and there is real engineering here. But
the repo has no vocabulary in it from regulated environments, and that is what
the panel will probe. Expect:

- *"Walk me through the qBittorrent VPN routing. Why fwmark instead of a
  namespace?"* — Strongest ground. Have the answer ready, including the
  tradeoff, and mention the H2 leak path unprompted; catching your own bug is
  the best possible answer to this question.
- *"How do you know a change is safe before you apply it to the server?"* —
  Currently: `nixos-rebuild dry-build`, plus CI that doesn't build. Weak. This
  is where `nixos-rebuild build-vm` and `pkgs.nixosTest` belong.
- *"How would you roll back a bad change at 2am?"* — The honest answer is good
  (`nixos-rebuild --rollback`, boot generation selection), but it is nowhere in
  the docs. Write it down.
- *"What's your recovery point objective for the photo library?"* — No answer
  today. See H3.
- *"How do you know the server is healthy right now?"* — A dashboard you have to
  look at. See H4.

Genuinely absent, and each one is a differentiator if added:

- **Automated testing.** `pkgs.nixosTest` spins up VMs and asserts on service
  behavior. Even one test — "boot the server config, assert nginx serves 443,
  assert qBittorrent cannot reach the internet with `mullvad0` down" — would put
  this repo in a different category. It directly answers H2, and almost no
  homelab repo has it.
- **Baseline hardening as code.** Nothing references CIS, STIG, or the NixOS
  `profiles/hardened.nix`. Even applying a subset — `systemd` sandboxing
  directives on the custom units, `boot.loader.systemd-boot.editor = false`,
  `security.auditd` with a rule set, `boot.kernel.sysctl` hardening — and
  documenting *why each one was chosen or rejected* demonstrates exactly the
  posture this industry hires for.
- **Provenance and supply chain.** Nix is unusually strong here and the repo
  doesn't use it. Content-addressed store paths, `nix path-info --sigs` for
  binary-cache trust, an SBOM from the derivation graph, a demonstrated offline
  or air-gapped build against a local cache — all of these translate directly to
  program requirements and none of them require special hardware.
- **Change control artifacts.** PR templates, `CODEOWNERS`, branch protection,
  a documented rollback procedure. Cheap, and they read as "has worked somewhere
  that audits changes".

---

## 5. Recommended sequence

Ordered by reviewer-visible impact per hour spent.

**First pass — under two hours, changes the first impression completely**

1. Fix the five formatting failures and get `main` green. Add a `just fmt-all`
   recipe that formats rather than checks. (H1)
2. Write a top-level `README.md`: what the estate is, the four hosts and their
   roles, a topology sketch, the bootstrap procedure, and one paragraph on the
   qBittorrent VPN routing design with a pointer to the module. Add a `LICENSE`.
   (M2)
3. Rewrite `CLAUDE.md`'s architecture and commands sections to match the code
   that exists. (M1)

**Second pass — a weekend, fixes the posture contradictions**

4. `services.openssh.ports = [ 2228 ]`, verified with a second session open. (C2)
5. Enable the firewall on one host, verify with `ss -tlnp` and an off-tailnet
   scan, then roll to the rest. Correct every comment and SPEC line that
   currently overstates what is enforced. (C1)
6. Bind Open WebUI and Ollama to loopback; re-enable `WEBUI_AUTH`. (C4)
7. Narrow the `jrhassistant` sudo rule to a fixed argv, and write down the
   threat model in a comment. (C3)
8. Fix the kill-switch established-state rule, then test it by downing the
   tunnel with an active torrent and watching the physical interface. (H2)
9. Gitignore `.claude/settings.local.json`; move the coordinates and Feedly UUID
   out of the public tree. (L2, L3)

**Third pass — the work that changes the level read**

10. One `nixosTest` asserting the kill switch. This is the single highest-value
    addition available to this repo.
11. Backups with a documented, *performed* restore, timed and written into
    `server/SPEC.md`. (H3)
12. One working alert path — smartd plus ZED, delivered somewhere you'll see it.
    (H4)
13. Build at least one host's `system.build.toplevel` in CI, source CI tooling
    from `flake.lock`, add a `formatter` output. (L1)
14. Branch protection on `main` requiring the check; a scheduled `nix flake
    update` PR. (L4, L5)
15. Refactor `flake.nix` to a `mkHost` helper. (M8)

---

## 6. Summary for the hiring file

**Recommendation:** advance. Strong systems fundamentals with demonstrated
ability to debug at the kernel networking and systemd-ordering layers — the
Mullvad/qBittorrent routing design and the ZFS mount-ordering fixes are both
things you cannot produce without genuinely understanding the layer underneath.
The declarative infrastructure practice is idiomatic and the per-host SPEC
documents show unusual instinct for separating requirements from implementation.

**Reservations:** verification and operational discipline lag the systems
ability by a wide margin. CI red on `main` for five weeks, no builds in CI, no
tests, no backups, no alerting, and a documented security posture that the
configuration does not implement. In a regulated program these are the graded
areas, and they are the areas the candidate has invested least in.

**The gap is closable and mostly cheap.** Nothing in Section 5 requires new
hardware or new fundamentals — it requires finishing. If the candidate returns
with green CI, a real README, a `nixosTest` covering the kill switch, and a
tested restore, the reservations evaporate and the level read moves up a band.
That would be a strong signal on its own: it is exactly the "found the gap,
closed it, verified it" loop the work actually consists of.
