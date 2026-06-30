# dev-env — meta-repo dev-environment

A tiny, secret-free meta-repo that provisions a machine, manages sops+age secrets
via mise, and produces encrypted backups. Clone it, run one script.

## Quick start (Windows)
1. Install [scoop](https://scoop.sh) (or let `init` do it).
2. Open PowerShell **as administrator**.
3. `git clone <repo> dev-env && cd dev-env`
4. Preview: `./scripts/init.ps1 -WhatIf`  → then `./scripts/init.ps1`
5. Open a new shell — mise + secrets auto-load.

## Actions
| Verb | Purpose |
|------|---------|
| `scripts/init.ps1` | provision/refresh this machine |
| `scripts/verify.ps1` | read-only health check |
| `scripts/update.ps1` | pull + update tools + re-apply chezmoi |
| `scripts/backup.ps1` | age-encrypted snapshot → `backups/` (also daily) |
| `scripts/restore.ps1` | decrypt + staged restore |

All support `--help` and `-WhatIf`; `restore`/`update` prompt unless `-Yes`.

## Backups
`backup` writes `backups/dev-backup-<timestamp>.tar.age` (git bundles of the
meta-repo + each `ops/<repo>`, age-encrypted to your public key). **You** choose
where to sync `backups/` — point Proton/Drive/Dropbox/Syncthing at it. Because it's
encrypted at rest, the provider only ever sees ciphertext.

## Disaster recovery
1. Install scoop, git, age; clone this repo.
2. Restore your age **private** key from Vaultwarden/Bitwarden to
   `~/.config/sops/age/keys.txt`.
3. `./scripts/restore.ps1` (or, before scripts exist:
   `age -d -i ~/.config/sops/age/keys.txt backups/<archive>.tar.age | tar -x`).
4. `git clone` each `*.bundle` from the staging dir to rebuild repos.
5. `./scripts/init.ps1` to finish provisioning.
