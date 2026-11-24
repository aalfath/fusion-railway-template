# Changelog

Each entry is one version of this Railway template. Breaking changes are listed first.

## 1.3.1 (2026-11-24)

- First release of the template: Fusion 1.3.1, official image `ghcr.io/0x2e/fusion:1.3.1` pinned by digest `sha256:e1a7410d8b424e7a5f2195a858900291e138d99211eb2f12553627ed48c66fe2`.
- One service with a volume at `/data` (SQLite database `fusion.db`).
- Generated `FUSION_PASSWORD`; the start script refuses to start without a password.
- Go runtime sized to the service's limits (`GOMAXPROCS` from cgroup `cpu.max`, `GOMEMLIMIT` at 70% of `memory.max`, transparent huge pages off), feed pull concurrency 4, Railway's edge headers trusted so login rate limiting sees the visitor's IP.
