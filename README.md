[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/fusion?utm_medium=integration&utm_source=button&utm_campaign=fusion)

# Fusion on Railway

A one-click Railway template for [Fusion](https://github.com/0x2E/fusion), a lightweight self-hosted RSS reader written in Go with SQLite (MIT licence).

## What it deploys

| Service | Source | What it does |
|---|---|---|
| `Fusion` | this repo's `Dockerfile` (`FROM ghcr.io/0x2e/fusion:1.3.1@sha256:e1a7410d…`) | The web app, the Fever API and the background feed puller, on Railway's `PORT`, with a public domain and a health check on `/api/oidc/enabled` |

- **Version:** Fusion 1.3.1, official image pinned by version and digest.
- **Storage:** one Railway volume at `/data`, holding the SQLite database `/data/fusion.db` (feeds, groups, articles, bookmarks, settings).
- **Memory:** about 20–40 MB in use; fits Railway's Free plan (0.5 GB per service).

## Variables

| Variable | Default | Notes |
|---|---|---|
| `FUSION_PASSWORD` | `${{secret(24)}}` | The login password, generated at deploy. Read it in the service's **Variables** tab. |
| `PORT` | `8080` | Port the app listens on. |

Optional settings you can add later (see upstream's [`.env.example`](https://github.com/0x2E/fusion/blob/v1.3.1/.env.example)): `FUSION_FEVER_USERNAME` (Fever API clients such as Reeder, default `fusion`), `FUSION_PULL_INTERVAL` (seconds, default 1800), `FUSION_OIDC_*` for single sign-on (redirect URI `https://YOUR-DOMAIN/api/oidc/callback`), `FUSION_CORS_ALLOWED_ORIGINS`.

## After deploy

1. Open the service's public URL.
2. Copy `FUSION_PASSWORD` from the service's Variables tab and log in.
3. Add feeds (or import an OPML file) and start reading.

## The start script

`railway-start.sh` runs before the upstream binary:

- sets `GOMAXPROCS` from the cgroup CPU limit and `GOMEMLIMIT` at 70% of the memory limit, and turns transparent huge pages off for the Go heap (Railway shows the host's CPUs inside a small service);
- keeps the database at `/data/fusion.db`, checks the volume is writable and refuses to start without a password, so a broken deploy exits non-zero and Railway restarts it;
- trusts Railway's proxy range (`100.64.0.0/10`) so the login rate limiter sees the visitor's IP;
- limits feed pulls to 4 at a time.

## Updates

When a new Fusion release comes out, this repo's `Dockerfile` pin is bumped and a `CHANGELOG.md` entry added. Railway then shows an "update available" notice on projects deployed from this template; read the changelog and apply it when it suits you. Your volume and password are kept.
