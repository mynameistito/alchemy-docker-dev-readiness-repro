# Alchemy Docker dev readiness reproduction

`alchemy dev` reports **Dev stack ready (3/3)** even though Docker cannot start and the container worker returns HTTP 502. A plain worker in the same stack returns HTTP 200.

## Requirements

Linux or WSL, Bash, and Bun. Tested on Ubuntu 26.04.1 under WSL2, Bun 1.4.4, Node 26.13.0. Alchemy and the Cloudflare provider are pinned to 2.0.0-beta.84; Effect is pinned to 4.0.7. The committed Bun lockfile pins transitive dependencies.

No Cloudflare credentials or running Docker daemon are needed for the failure reproduction. Use free ports 14337 and 14338. Run one instance at a time.

## Reproduce

```sh
bun install --frozen-lockfile
bash reproduce.sh spawn
```

Run in an interactive terminal to see the readiness widget. The repo-local `docker` fixture has a deliberately missing shebang interpreter, causing `posix_spawn 'docker'` to fail with ENOENT. The PATH change affects only the repro process tree; it does not modify Docker or stop any daemon.

In another terminal:

```sh
bash verify.sh
```

Expected observed output:

```text
healthy worker: HTTP 200
container worker: HTTP 502
Confirmed: healthy worker serves requests while container worker fails.
```

The Alchemy terminal logs a raw spawn exception and nevertheless displays:

```text
ENOENT: no such file or directory, posix_spawn 'docker'
Dev stack ready (3/3)
```

Press Ctrl+C to stop. If a forced termination leaves a sidecar behind, stop that repro process before rerunning; occupied ports produce a different startup failure.

### Alternative: Docker CLI runs but daemon is unavailable

```sh
bash reproduce.sh daemon
```

This fixture prints a daemon-unavailable message and exits 1. It produces a structured `DockerPullFailed` error with the useful hint `Ensure Docker is running and the image is available.` The stack still reports successful resource creation in noninteractive output. The spawn case above lacks that actionable Docker-specific explanation.

## Expected behavior

Surface a Docker-specific startup diagnostic for executable/spawn failures, and mark the container worker failed/degraded rather than reporting the entire dev stack ready. Keeping unrelated workers available is useful; the overall status should reflect the failed worker.

## Scope

Two workers, one container, local state, and a tiny BusyBox Dockerfile. No application code, database, proxy, tokens, or deployment configuration. The synthetic ENOENT is intentionally distinct from the original Docker Desktop/WSL EIO: it exercises the same executable-spawn failure path deterministically without reproducing a broken WSL mount.
