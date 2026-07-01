# SQLite

Embedded SQL database and the `sqlite3` CLI — handy for local data, quick inspection, and
prototyping (Forgejo itself runs on SQLite here).

- **Install:** Linux — `sudo apt install sqlite3`; Windows — `winget install SQLite.SQLite` (or the tools zip from sqlite.org). Binary not committed.
- **Use:** `sqlite3 path/to.db` then `.tables`, `.schema`, `.quit`.
- Backed up via this manifest entry, not the binary.
