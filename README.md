# dev — meta-repo dev-environment

A tiny, secret-free meta-repo that provisions a machine, manages sops+age secrets
via mise, and produces encrypted backups. Clone it, run one script. Runs in
WSL/Linux (bash).

## Quick start
1. `git clone <repo> dev && cd dev`
2. Preview: `./install.sh --dry-run`  → then `./install.sh`
3. Open a new shell — mise + secrets auto-load.

## Scripts
| Script | Purpose |
|--------|---------|
| `./install.sh` | provision/refresh this machine |
| `./backup.sh` | age-encrypted snapshot → `backup/` (manual — run it when you want one) |
| `./restore.sh` | decrypt + staged restore |

All support `--help` and `--dry-run`; `restore` prompts unless `--yes`.

## Backups
`backup` writes `backup/dev-backup-<timestamp>.tar.age` — git bundles of the
meta-repo + each `ops/<repo>` (including `ops/infra`), age-encrypted to your public
key. **You** choose where to sync `backup/` — point Proton/Drive/Syncthing at it;
encrypted at rest, the provider only ever sees ciphertext.

> Live service state (the Forgejo DB, container volumes) is **not** in these bundles.
> It's dumped separately by `ops/infra` (see `ops/infra/RESTORE.md`). Rule of thumb:
> git bundles cover code + config; the Forgejo dump covers live data.

## Disaster recovery
1. Install git + age; clone this repo.
2. Restore your age **private** key from Vaultwarden/Bitwarden to
   `~/.config/sops/age/keys.txt`.
3. `./restore.sh` (or, before scripts exist:
   `age -d -i ~/.config/sops/age/keys.txt backup/<archive>.tar.age | tar -x`).
4. `git clone` each `*.bundle` from the staging dir to rebuild repos.
5. `./install.sh` to finish provisioning.
