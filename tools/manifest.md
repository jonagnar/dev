# tools/manifest.md — GUI / desktop apps (mise can't manage these)

Machine-global CLIs live in `.config/mise/core.toml` (add with `mise use -g`).
This documents per-machine tools *not* in mise core — GUI apps, optional CLIs,
and local tools. Binaries in `tools/bin/` aren't committed (re-downloadable);
this manifest and any committed tool source (e.g. `tools/md2pdf/`) are.

| Tool | What / install |
|------|----------------|
| Bruno (API client) | GUI, Git-friendly API client. `scoop install bruno` (or winget). See `tools/bruno/`. |
| SQLite (`sqlite3`) | CLI + embedded DB for local data/inspection. `scoop install sqlite`. See `tools/sqlite/`. |
| tea (Forgejo CLI) | Forgejo/Gitea CLI (PRs/issues/repos). Binary lives at `tools/bin/tea` (re-download from Gitea `tea` releases). See `tools/tea/`. |
| md2pdf | Optional Markdown→PDF renderer (WeasyPrint). Source in `tools/md2pdf/`; run its `setup.sh` to build the `.venv`. **Not** part of core tooling. |
