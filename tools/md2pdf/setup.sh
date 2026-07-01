#!/usr/bin/env bash
# Create the venv and install Python deps for md2pdf.
# PREREQ (run first, needs root):
#   sudo apt install python3-venv python3-pip libpango-1.0-0 libpangoft2-1.0-0
set -euo pipefail
cd "$(dirname "$0")"
python3 -m venv .venv
./.venv/bin/pip install --upgrade pip
./.venv/bin/pip install -r requirements.txt
echo "OK — md2pdf ready. Try: .venv/bin/python md2pdf.py sample.md -o sample.pdf"
