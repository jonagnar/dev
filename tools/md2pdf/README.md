# md2pdf

Render a Markdown spec/plan to a **jonnxor.is-styled PDF** (dawn theme: Orbitron headings,
Montserrat body, JetBrains Mono code; A4, page numbers in the footer). Self-contained — the
fonts are baked in, so it renders identically without jonnxor.is checked out.

## Setup (one-time)
1. System libs (needs root): `sudo apt install python3-venv python3-pip libpango-1.0-0 libpangoft2-1.0-0`
2. Python deps: `bash setup.sh`

## Usage
```
.venv/bin/python md2pdf.py <input.md> [-o <output.pdf|dir>] [--title "..."]
```

Used in the SDD promote step: author the `.md` in `code/<project>/.planning/`, render the PDF into
`resources/<project>/{specs,plans}/`.
