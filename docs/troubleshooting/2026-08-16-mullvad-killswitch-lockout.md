# Mullvad Killswitch Lockout After Channel Downgrade

| | |
|---|---|
| **Date** | 2026-08-16 |
| **Host** | `desktop` |
| **Channel at failure** | nixpkgs unstable |
| **NixOS Unstable Version** | 26.11.20260816.e5bdc4a (Zokor) |
| **Unstable Kernel** | 7.1.8 |
| **NixOS Stable Version** | 26.05 (Yarara) |
| **Stable Kernel** | 7.1.2 |
| **Impact** | Total loss of IP connectivity; persisted across reboots and generation rollbacks |
| **Time to resolution** | three hours |
| **Root cause** | Mullvad VPN killswitch (lockdown mode) nftables rules rejecting all egress at OUTPUT |

---

## Symptom

While downgrading `desktop` from nixpkgs unstable to stable to investigate
unrelated stability issues, the host lost all IP connectivity. No address was
reachable, including the default gateway on the local subnet. Initial address 
of host was 10.0.0.223 and after a DHCP renewal the ip address became 10.0.0.125.

```
$ ping -c3 10.0.0.1
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
From 10.0.0.223 icmp_seq=1 Destination Port Unreachable
ping: sendmsg: Operation not permitted
3 packets transmitted, 0 received, +3 errors, 100% packet loss, time 2042ms
```

Other hosts on the same network were unaffected. The interface had
worked normally prior to the downgrade.

---

## Environment

Two interfaces were up during the initial session: `eno1` (wired) and `wlp6s0`
(wireless), both holding addresses on the same /24. Wireless was disabled early
in troubleshooting to remove the ambiguity.

```
$ ip -br addr
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eno1             UP             10.0.0.125/24 
wlp6s0           DOWN           
tailscale0       UNKNOWN        fe80::2d18:3eda:acd7:f3e0/64 

```

```
$ ip -br link
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP> 
eno1             UP             74:56:3c:72:24:99 <BROADCAST,MULTICAST,UP,LOWER_UP> 
wlp6s0           DOWN           e6:30:b8:f6:03:3c <BROADCAST,MULTICAST> 
tailscale0       UNKNOWN        <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> 
```


```
$ systemctl is-active NetworkManager systemd-networkd dhcpcd tailscaled mullvad-daemon
active
inactive
inactive
active
active
```

`tailscale0` remained up throughout, carrying only a link-local IPv6 address. It
is eliminated as a cause under *Tailscale policy rules were present but inert*
below, but its presence in the captures above is why it was suspected first.

---

## Troubleshooting

Presented as observation → what it eliminated, rather than chronologically.

### Packet filtering was ruled out on a faulty premise

`modules/nixos/common.nix` contained:

```nix
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  networking.nftables.enable = false;
  networking.firewall.checkReversePath = "loose";
```

This was read as "no packet filtering is active," and filtering was set aside as
a hypothesis for the remainder of the first session. **This inference was wrong**
and is analyzed under *Root cause* below.

### Routing was correct

```
$ ip route show
default via 10.0.0.1 dev eno1 proto dhcp src 10.0.0.125 metric 100
10.0.0.0/24 dev eno1 proto kernel scope link src 10.0.0.125 metric 100
```

```
$ ip route get 1.1.1.1
1.1.1.1 via 10.0.0.1 dev eno1 src 10.0.0.125 uid 1000
  cache
```

The kernel selected the correct interface, source address, and next hop.
**Eliminated:** missing or malformed routes, wrong interface selection.

### Tailscale policy rules were present but inert

`tailscaled` was reporting `connected but missing profile` — consistent with the
older stable-channel binary being unable to read a `tailscaled.state` file
written by the newer unstable version. Residual policy rules were present:

```
$ ip rule show
0:      from all lookup local
5210:   from all fwmark 0x80000/0xff0000 lookup main
5230:   from all fwmark 0x80000/0xff0000 lookup default
5250:   from all fwmark 0x80000/0xff0000 unreachable
5270:   from all lookup 52
32766:  from all lookup main
32767:  from all lookup default
```

This became the primary hypothesis: rule 5270 matches unconditionally, so if
table 52 contained a default route through a dead `tailscale0`, all egress would
be blackholed. The hypothesis was falsified by:

```
$ ip route show table 52
Error: ipv4: FIB table does not exist
Dump terminated
```

A lookup into a nonexistent table fails and falls through to the next rule,
terminating at 32766 (`main`) — which is exactly what `ip route get` had already
shown. Rules 5210/5230/5250 are fwmark-conditional and do not match ordinary
traffic. **Eliminated:** Tailscale policy routing.

### Layer 1 and 2 were proven working by DHCP

The reserved lease was deleted at the router and the interface renewed, yielding
10.0.0.125. A successful DHCP transaction is a four-packet round trip
(DISCOVER/OFFER/REQUEST/ACK) with the router.

**Eliminated in one observation:** cable, NIC driver, switch port, VLAN
assignment, and duplicate IP address. The router and host were exchanging frames
bidirectionally.

### ICMP replies were never returned

```
$ ping -c5 1.1.1.1
$ nstat -az | grep -iE 'IcmpOutEcho|IcmpInEchoRep|IpOutDiscards|IpOutNoRoutes'
IpOutDiscards                   80415              0.0
IpOutNoRoutes                   0                  0.0
IcmpInEchoReps                  2                  0.0
IcmpOutEchos                    52                 0.0
IcmpOutEchoReps                 0                  0.0
```

A baseline reading was taken before the ping. `IcmpOutEchos` incremented from 47
to 52 — five echo requests, matching `ping -c5`. `IcmpInEchoReps` did not move
from its pre-test value of 2, so no replies were received. Note that `nstat -az`
prints absolute counters and does not reset them; the deltas above come from
comparing two readings, not from zeroing.

**Eliminated:** the possibility that replies were arriving and being discarded on
ingress. Nothing came back.

This also reconciles an apparent contradiction. `IcmpOutEchos` incremented even
though `sendmsg` returned `EPERM` and no packet reached the wire, because the
ICMP layer counts a datagram when it hands it to IP — before the netfilter OUTPUT
hook renders a verdict. The rejected packets are then accounted separately, which
is consistent with the large `IpOutDiscards` value and with `IpOutNoRoutes` at
zero: the kernel had a route and chose not to use it, rather than lacking one.

### Generation rollback did not resolve it

Booting an older unstable generation restored connectivity. Pulling the newest
flake and rebuilding — unstable → unstable, identical kernel — reproduced the
failure.

**Eliminated:** kernel regression, driver regression, channel downgrade itself.
This narrowed the cause to something introduced between two generations, or to
state that is not part of a generation at all.

The one older generation that worked did not have Mullvad enabled, confirmed by
inspecting that generation's closure in the Nix store. This was established only
after the root cause was known, and is recorded here as corroboration rather than
as a step in the diagnosis.

``ls /nix/var/nix/profiles/system-46-link/etc/systemd/system | grep -i mullvad``

---

## Root cause

Mullvad VPN's killswitch (lockdown mode) was armed. Its nftables ruleset installs
an `output` chain with `policy drop` whose only accepts are loopback, traffic
already marked as belonging to the tunnel, DHCP, IPv6 neighbor discovery, and a
single hard-coded API endpoint. Everything else falls through to a terminal
`reject`. With no tunnel established, that meant all ordinary egress.

`sendmsg: Operation not permitted` is a kernel-level `EPERM` returned to the
socket — it indicates local packet filtering, not a routing or link failure. This
was present in the very first error message of the incident.

```
$ nix shell nixpkgs#nftables

$ sudo nft list ruleset
table inet mullvad {
        chain prerouting {
                type filter hook prerouting priority -199; policy accept;
        }

        chain output {
                type filter hook output priority filter; policy drop;
                oif "lo" accept
                ct mark 0x00000f41 accept
                udp sport 68 ip daddr 255.255.255.255 udp dport 67 accept
                ip6 saddr fe80::/10 udp sport 546 ip6 daddr ff02::1:2 udp dport 547 accept
                ip6 saddr fe80::/10 udp sport 546 ip6 daddr ff05::1:3 udp dport 547 accept
                ip6 daddr ff02::2 icmpv6 type nd-router-solicit icmpv6 code 0 accept
                ip6 daddr ff02::1:ff00:0/104 icmpv6 type nd-neighbor-solicit icmpv6 code 0 accept
                ip6 daddr fe80::/10 icmpv6 type nd-neighbor-solicit icmpv6 code 0 accept
                ip6 daddr fe80::/10 icmpv6 type nd-neighbor-advert icmpv6 code 0 accept
                ip daddr 45.83.223.196 tcp dport 443 meta skuid 0 accept
                udp dport 53 reject
                tcp dport 53 reject with tcp reset
                reject
        }

        chain input {
                type filter hook input priority filter; policy drop;
                iif "lo" accept
                ct mark 0x00000f41 accept
                udp sport 67 udp dport 68 accept
                ip6 saddr fe80::/10 udp sport 547 ip6 daddr fe80::/10 udp dport 546 accept
                ip6 saddr fe80::/10 icmpv6 type nd-router-advert icmpv6 code 0 accept
                ip6 saddr fe80::/10 icmpv6 type nd-redirect icmpv6 code 0 accept
                ip6 saddr fe80::/10 icmpv6 type nd-neighbor-solicit icmpv6 code 0 accept
                icmpv6 type nd-neighbor-advert icmpv6 code 0 accept
                ip saddr 45.83.223.196 tcp sport 443 ct state established meta skuid 0 accept
        }

        chain forward {
                type filter hook forward priority filter; policy drop;
                ct mark 0x00000f41 accept
                udp sport 68 ip daddr 255.255.255.255 udp dport 67 accept
                udp sport 67 udp dport 68 accept
                ip6 saddr fe80::/10 udp sport 546 ip6 daddr ff02::1:2 udp dport 547 accept
                ip6 saddr fe80::/10 udp sport 546 ip6 daddr ff05::1:3 udp dport 547 accept
                ip6 saddr fe80::/10 udp sport 547 ip6 daddr fe80::/10 udp dport 546 accept
                ip6 daddr ff02::2 icmpv6 type nd-router-solicit icmpv6 code 0 accept
                ip6 saddr fe80::/10 icmpv6 type nd-router-advert icmpv6 code 0 accept
                ip6 saddr fe80::/10 icmpv6 type nd-redirect icmpv6 code 0 accept
                ip6 daddr ff02::1:ff00:0/104 icmpv6 type nd-neighbor-solicit icmpv6 code 0 accept
                ip6 daddr fe80::/10 icmpv6 type nd-neighbor-solicit icmpv6 code 0 accept
                ip6 saddr fe80::/10 icmpv6 type nd-neighbor-solicit icmpv6 code 0 accept
                ip6 daddr fe80::/10 icmpv6 type nd-neighbor-advert icmpv6 code 0 accept
                icmpv6 type nd-neighbor-advert icmpv6 code 0 accept
                udp dport 53 reject
                tcp dport 53 reject with tcp reset
                reject
        }

        chain mangle {
                type route hook output priority mangle; policy accept;
                meta cgroup 5087041 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
        }

        chain nat {
                type nat hook postrouting priority srcnat; policy accept;
                oif != "lo" ct mark 0x00000f41 masquerade
        }
}

```

The bare `reject` at the end of the `output` chain accounts for both lines of the
original error. In an `inet` table the default reject verdict is an ICMP
port-unreachable, which is the `Destination Port Unreachable` line; the verdict
delivered back to a locally-generated packet's socket is `EPERM`, which is the
`sendmsg` line. One rule, both symptoms — and the symptom text was therefore
naming the mechanism from the first minute of the incident.

### The killswitch prevented its own release

Two rules in the same chain explain why the daemon never recovered on its own:

```
ip daddr 45.83.223.196 tcp dport 443 meta skuid 0 accept
udp dport 53 reject
tcp dport 53 reject with tcp reset
```

The Mullvad API endpoint is permitted by address, but DNS is rejected outright.
The daemon resolves that endpoint by hostname, so its own ruleset blocked the
lookup it needed to reach the API, obtain server configuration, and build the
tunnel that would have lifted the killswitch. The daemon log below shows this
loop running for roughly three hours: `failed to lookup address information: Name
or service not known`, retried at widening intervals, with a
`Applying firewall policy: Blocked` at the head of it.

```
$ journalctl -u mullvad-daemon -b
Aug 16 21:31:45 desktop systemd[1]: Started Mullvad VPN daemon.
Aug 16 21:31:45 desktop mullvad-daemon[1439]:  INFO mullvad_daemon::version: Starting mullvad-daemon - 2026.3
Aug 16 21:31:45 desktop mullvad-daemon[1439]:  INFO mullvad_daemon: Logging to /var/log/mullvad-vpn/daemon.log
Aug 16 21:31:45 desktop mullvad-daemon[1439]:  INFO mullvad_daemon::settings: Loading settings from /etc/mullvad-vpn/settings.json
Aug 16 21:31:45 desktop mullvad-daemon[1439]:  INFO mullvad_daemon::management_interface: Management interface listening on /var/run/mullvad-vpn
Aug 16 21:31:45 desktop mullvad-daemon[1439]:  INFO mullvad_daemon::account_history: Opening account history file in /etc/mullvad-vpn/account-history.json
Aug 16 21:31:45 desktop mullvad-daemon[1439]:  INFO talpid_core::firewall: Applying firewall policy: Blocked. Blocking LAN. Allowing endpoint: 45.83.223.196:443/TCP
Aug 16 21:31:46 desktop mullvad-daemon[1439]:  INFO mullvad_daemon::api: Initial offline state - online
Aug 16 21:31:46 desktop mullvad-daemon[1439]: ERROR mullvad_api::rest: Error: HTTP request failed
Aug 16 21:31:46 desktop mullvad-daemon[1439]: Caused by: Legacy hyper error
Aug 16 21:31:46 desktop mullvad-daemon[1439]: Caused by: client error (Connect)
Aug 16 21:31:46 desktop mullvad-daemon[1439]: Caused by: failed to lookup address information: Name or service not known
Aug 16 21:31:46 desktop mullvad-daemon[1439]: ERROR mullvad_api::rest: Error: HTTP request failed
Aug 16 21:31:46 desktop mullvad-daemon[1439]: Caused by: Legacy hyper error
Aug 16 21:31:46 desktop mullvad-daemon[1439]: Caused by: client error (Connect)
Aug 16 21:31:46 desktop mullvad-daemon[1439]: Caused by: failed to lookup address information: Name or service not known
Aug 16 21:31:49 desktop mullvad-daemon[1439]: ERROR mullvad_api::rest: Error: HTTP request failed
Aug 16 21:31:49 desktop mullvad-daemon[1439]: Caused by: Legacy hyper error
Aug 16 21:31:49 desktop mullvad-daemon[1439]: Caused by: client error (Connect)
Aug 16 21:31:49 desktop mullvad-daemon[1439]: Caused by: failed to lookup address information: Name or service not known
Aug 16 21:31:59 desktop mullvad-daemon[1439]: ERROR mullvad_api::rest: Error: HTTP request failed
Aug 16 21:31:59 desktop mullvad-daemon[1439]: Caused by: Legacy hyper error
Aug 16 21:31:59 desktop mullvad-daemon[1439]: Caused by: client error (Connect)
Aug 16 21:31:59 desktop mullvad-daemon[1439]: Caused by: failed to lookup address information: Name or service not known
Aug 16 21:32:09 desktop mullvad-daemon[1439]: ERROR mullvad_api::rest: Error: HTTP request failed
Aug 16 21:32:09 desktop mullvad-daemon[1439]: Caused by: Legacy hyper error
Aug 16 21:32:09 desktop mullvad-daemon[1439]: Caused by: client error (Connect)
Aug 16 21:32:09 desktop mullvad-daemon[1439]: Caused by: failed to lookup address information: Name or service not known
Aug 16 21:34:04 desktop mullvad-daemon[1439]: ERROR mullvad_api::rest: Error: HTTP request failed
Aug 16 21:34:04 desktop mullvad-daemon[1439]: Caused by: Legacy hyper error
Aug 16 21:34:04 desktop mullvad-daemon[1439]: Caused by: client error (Connect)
Aug 16 21:34:04 desktop mullvad-daemon[1439]: Caused by: failed to lookup address information: Name or service not known
Aug 16 21:50:27 desktop mullvad-daemon[1439]: ERROR mullvad_api::rest: Error: HTTP request failed
Aug 16 21:50:27 desktop mullvad-daemon[1439]: Caused by: Legacy hyper error
Aug 16 21:50:27 desktop mullvad-daemon[1439]: Caused by: client error (Connect)
Aug 16 21:50:27 desktop mullvad-daemon[1439]: Caused by: failed to lookup address information: Name or service not known
Aug 16 22:00:27 desktop mullvad-daemon[1439]:  INFO mullvad_daemon::api: Detecting changes to offline state - Offline
Aug 16 22:00:28 desktop mullvad-daemon[1439]:  INFO mullvad_daemon::api: Detecting changes to offline state - Online(Ipv4)
Aug 16 22:05:52 desktop mullvad-daemon[1439]: ERROR mullvad_api::rest: Error: HTTP request failed
Aug 16 22:05:52 desktop mullvad-daemon[1439]: Caused by: Legacy hyper error
Aug 16 22:05:52 desktop mullvad-daemon[1439]: Caused by: client error (Connect)
Aug 16 22:05:52 desktop mullvad-daemon[1439]: Caused by: failed to lookup address information: Name or service not known
Aug 16 22:11:14 desktop mullvad-daemon[1439]: ERROR mullvad_api::rest: Error: HTTP request failed
Aug 16 22:11:14 desktop mullvad-daemon[1439]: Caused by: Legacy hyper error
Aug 16 22:11:14 desktop mullvad-daemon[1439]: Caused by: client error (Connect)
Aug 16 22:11:14 desktop mullvad-daemon[1439]: Caused by: failed to lookup address information: Name or service not known
Aug 16 22:25:58 desktop mullvad-daemon[1439]:  INFO talpid_core::firewall: Resetting firewall policy
Aug 17 00:11:24 desktop mullvad-daemon[1439]:  INFO talpid_core::firewall: Applying firewall policy: Blocked. Blocking LAN. Allowing endpoint: 45.83.223.196:443/TCP
Aug 17 00:11:24 desktop mullvad-daemon[1439]: ERROR mullvad_api::rest: Error: HTTP request failed
Aug 17 00:11:24 desktop mullvad-daemon[1439]: Caused by: Legacy hyper error
Aug 17 00:11:24 desktop mullvad-daemon[1439]: Caused by: client error (Connect)
Aug 17 00:11:24 desktop mullvad-daemon[1439]: Caused by: failed to lookup address information: Name or service not known
Aug 17 00:11:24 desktop mullvad-daemon[1439]: ERROR mullvad_api::rest: Error: HTTP request failed
Aug 17 00:11:24 desktop mullvad-daemon[1439]: Caused by: Legacy hyper error
Aug 17 00:11:24 desktop mullvad-daemon[1439]: Caused by: client error (Connect)
Aug 17 00:11:24 desktop mullvad-daemon[1439]: Caused by: failed to lookup address information: Name or service not known
Aug 17 00:11:26 desktop mullvad-daemon[1439]: ERROR mullvad_api::rest: Error: HTTP request failed
Aug 17 00:11:26 desktop mullvad-daemon[1439]: Caused by: Legacy hyper error
Aug 17 00:11:26 desktop mullvad-daemon[1439]: Caused by: client error (Connect)
Aug 17 00:11:26 desktop mullvad-daemon[1439]: Caused by: failed to lookup address information: Name or service not known
Aug 17 00:11:42 desktop mullvad-daemon[1439]: ERROR mullvad_api::rest: Error: HTTP request failed
Aug 17 00:11:42 desktop mullvad-daemon[1439]: Caused by: Legacy hyper error
Aug 17 00:11:42 desktop mullvad-daemon[1439]: Caused by: client error (Connect)
Aug 17 00:11:42 desktop mullvad-daemon[1439]: Caused by: failed to lookup address information: Name or service not known
Aug 17 00:12:03 desktop mullvad-daemon[1439]: ERROR mullvad_api::rest: Error: HTTP request failed
Aug 17 00:12:03 desktop mullvad-daemon[1439]: Caused by: Legacy hyper error
Aug 17 00:12:03 desktop mullvad-daemon[1439]: Caused by: client error (Connect)
Aug 17 00:12:03 desktop mullvad-daemon[1439]: Caused by: failed to lookup address information: Name or service not known
Aug 17 00:14:13 desktop mullvad-daemon[1439]: ERROR mullvad_api::rest: Error: HTTP request failed
Aug 17 00:14:13 desktop mullvad-daemon[1439]: Caused by: Legacy hyper error
Aug 17 00:14:13 desktop mullvad-daemon[1439]: Caused by: client error (Connect)
Aug 17 00:14:13 desktop mullvad-daemon[1439]: Caused by: failed to lookup address information: Name or service not known
Aug 17 00:24:09 desktop mullvad-daemon[1439]: ERROR mullvad_api::rest: Error: HTTP request failed
Aug 17 00:24:09 desktop mullvad-daemon[1439]: Caused by: Legacy hyper error
Aug 17 00:24:09 desktop mullvad-daemon[1439]: Caused by: client error (Connect)
Aug 17 00:24:09 desktop mullvad-daemon[1439]: Caused by: failed to lookup address information: Name or service not known

```

### Why it defeated diagnosis for two sessions

Three properties of the failure each independently pointed away from the answer.

**`networking.firewall.enable = false` is not evidence that no packet filtering is
active.** The option governs whether *NixOS* installs a ruleset. It says nothing
about what third-party daemons write directly into the kernel's nf_tables
subsystem. Mullvad, Tailscale, Docker, and libvirt all install rules independently
of the NixOS firewall module. Treating the declarative config as a complete
description of kernel state was the central error of the first session.

**The nftables ruleset is runtime state and does not roll back with a generation.**
It is installed by a running daemon, not built into the system closure. Rolling
back to a known-good generation therefore did not remove it — which made the
failure look like it was following the hardware or the kernel rather than a
service. This explains the most confusing evidence in the incident.

**``nft`` was not in ``PATH``, though it was present on the system.** The
nftables package was already in the store as a runtime dependency of
NetworkManager, and nix shell nixpkgs#nftables retrieved it offline —
the flake registry was pinned to a local store path, so evaluation required
no network. The tool was available throughout. It went unused because
networking.firewall.enable = false had been read as ruling out packet
filtering, so the check was never attempted. The failure was one of
hypothesis selection, not tooling availability.

```
$ nix registry list | grep nixpkgs
system flake:nixpkgs path:/nix/store/rd49sb5is1wap50ifnlm5amjpabwbdk1-source
global flake:nixpkgs https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz
global flake:nixpkgs/nixpkgs-unstable https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz
global flake:nixpkgs/nixos-unstable https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz
global flake:nixpkgs/nixos-unstable-small https://channels.nixos.org/nixos-unstable-small/nixexprs.tar.xz
global flake:nixpkgs/nixos-26.05 https://channels.nixos.org/nixos-26.05/nixexprs.tar.xz
global flake:nixpkgs/nixos-26.05-small https://channels.nixos.org/nixos-26.05-small/nixexprs.tar.xz
global flake:nixpkgs/nixpkgs-26.05-darwin https://channels.nixos.org/nixpkgs-26.05-darwin/nixexprs.tar.xz
global flake:nixpkgs github:NixOS/nixpkgs/nixpkgs-unstable

$ nix path-info -r /run/current-system | grep -i nftables
/nix/store/j48qz9i2684r8i9ng72sb06mhawvggyw-nftables-1.1.6
/nix/store/x84nd0r1wr36mb6qm10250xv6hd7575r-nftables-1.1.6

$ nix why-depends /run/current-system $(nix path-info -r /run/current-system | grep -m1 -i nftables)
/nix/store/x7wxs4kdlpv294blcf5vqjqb7qy6cmfb-nixos-system-desktop-26.11.20260816.e5bdc4a
└───/nix/store/al9203plzh312f1bszvhxs648k16nlym-system-path
    └───/nix/store/smg6s5kfg2m8nbcq6kq8bsdbqbh7naw9-networkmanager-1.58.0
        └───/nix/store/j48qz9i2684r8i9ng72sb06mhawvggyw-nftables-1.1.6

```

---

## Resolution

Immediate, to restore connectivity:

```bash
sudo nft flush ruleset
ping -c3 10.0.0.1        # replies returned immediately
```

This is runtime-only. The daemon reinstalls the ruleset on next start, so the
killswitch must also be disabled:

```bash
mullvad lockdown-mode get
mullvad lockdown-mode set off
mullvad status
```
After reboot ``mullvad status`` reports Disconnected and network connectivity is normal. 
Now that the error is known mullvad will remain enabled on this host.

---

## Prevention

**Diagnostic tooling is now unconditional.** The primary corrective action is
ensuring the tools needed to inspect kernel network state are in ``PATH`` *before*
they are needed.

```nix
environment.systemPackages = with pkgs; [
  nftables      # inspect netfilter state written by third-party daemons
  iptables      # nft-compat view; some daemons install legacy-style rules
  tcpdump
  ethtool
  dnsutils      # dig, nslookup
  traceroute
  mtr
];
```

`nftables` is declared explicitly rather than relying on
`networking.nftables.enable` to pull it in, so that availability of `nft` is not
coupled to a firewall configuration decision.

> [TODO] Link the commit that adds these, and add a comment in the Nix file
> pointing back at this document. The doc and the config change reinforce each
> other; neither is as strong alone.

**Deferred:** enabling `networking.firewall.enable = true`. Changing firewall
state while the Mullvad daemon fault is still unexplained would introduce a
variable into an unresolved system, and a failure would present identically to
the incident above. To be done as a separate, independently bisectable change
once the tunnel is confirmed healthy across a reboot.

---

## Retrospective

The decisive evidence — `sendmsg: Operation not permitted` — was present in the
first line of the first error message and was under-weighted for two sessions in
favor of a routing hypothesis that matched the symptom pattern but not the errno.
`EPERM` on `sendmsg` is specific: it is a local filtering verdict. `ENETUNREACH`
would have indicated a missing route, `EINVAL` a blackhole. The error already
distinguished between the hypotheses being tested.

The falsifying test for the Tailscale hypothesis (`ip route show table 52`) was
cheap and was run late. The falsifying test for the filtering hypothesis
(`nft list ruleset`) was not run until the end — not because the tool was
unavailable, but because the hypothesis had already been discarded on faulty
grounds and no reason to run it was perceived. A discarded hypothesis stops
generating tests, which is what makes the grounds for discarding it worth
scrutinizing.

Generalizable: on a declaratively-configured system, the configuration describes
what the system *installs*, not what is *running*. Runtime state written by
third-party daemons is invisible to the config, survives generation rollback, and
requires its own inspection tooling.
