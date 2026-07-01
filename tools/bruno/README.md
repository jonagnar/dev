# Bruno

Open-source, offline-first API client — a Git-friendly Postman alternative. Requests and
collections are plain-text `.bru` files that live **in the project repo** (e.g.
`code/<project>/tests/api/`), so they version and back up with the code.

- **Install:** Windows — `winget install Bruno.Bruno` (or the installer from usebruno.com). Binary not committed.
- **Use:** open a collection folder; environments hold base URLs / secrets — keep secrets out of git (reference env vars / sops-decrypted values).
- Backed up via this manifest entry, not the binary.
