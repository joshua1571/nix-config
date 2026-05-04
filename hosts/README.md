# Hosts

Each host has a `SPEC.md` describing its intended hardware, services,
networking, and known gaps. The SPEC is the source of truth for *what* the
host should do; the nix modules under `hosts/<name>/` and `modules/` are the
implementation.

| Host | Role | Spec |
|---|---|---|
| `laptop` | Portable workstation, game-streaming client | [SPEC](./laptop/SPEC.md) |
| `desktop` | Workstation, game-streaming server, emulation | [SPEC](./desktop/SPEC.md) |
| `server` | Headless media / automation / storage | [SPEC](./server/SPEC.md) |
| `htpc` | Living-room media client (Intel QSV) | [SPEC](./htpc/SPEC.md) |

## Reconciling a host with its spec

To have an agent close the gap between intent (SPEC) and implementation
(modules), run something like:

```
claude "Reconcile hosts/server with its SPEC.md. List drift first
(SPEC items not implemented, modules not in SPEC), then propose changes."
```

The SPECs are intentionally written so an agent can read one file and know
what services, ports, secrets, and storage layout are expected on that host.
