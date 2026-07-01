#!/usr/bin/env python3
"""md2pdf — render a Markdown file to a jonnxor.is-styled PDF (dawn theme).

Usage: md2pdf.py <input.md> [-o <output.pdf|dir>] [--title "..."]
"""
import argparse, re, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent


def derive_title(md_text: str, fallback: str) -> str:
    m = re.search(r'^\#\s+(.+?)\s*$', md_text, re.MULTILINE)
    return m.group(1).strip() if m else fallback


def md_to_html(md_text: str, title: str) -> str:
    import markdown
    body = markdown.markdown(
        md_text,
        extensions=["extra", "toc", "sane_lists"],
        output_format="html5",
    )
    esc = title.replace("&", "&amp;").replace("<", "&lt;")
    return (
        '<!doctype html><html lang="en"><head><meta charset="utf-8">'
        f"<title>{esc}</title>"
        '<link rel="stylesheet" href="style/fonts.css">'
        '<link rel="stylesheet" href="style/print.css">'
        f'</head><body><main class="doc">{body}</main></body></html>'
    )


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description="Render Markdown to a jonnxor.is-styled PDF.")
    ap.add_argument("input", help="input .md file")
    ap.add_argument("-o", "--output", help="output .pdf file or directory (default: <input>.pdf)")
    ap.add_argument("--title", help="document title (default: first H1, else filename)")
    args = ap.parse_args(argv)

    src = Path(args.input)
    if not src.is_file():
        print(f"md2pdf: input not found: {src}", file=sys.stderr)
        return 1

    if args.output:
        out = Path(args.output)
        if out.is_dir():
            out = out / (src.stem + ".pdf")
    else:
        out = src.with_suffix(".pdf")
    out.parent.mkdir(parents=True, exist_ok=True)

    md_text = src.read_text(encoding="utf-8")
    title = args.title or derive_title(md_text, src.stem)

    try:
        from weasyprint import HTML
    except ImportError:
        print("md2pdf: WeasyPrint not installed — run setup (see tools/md2pdf/README.md).", file=sys.stderr)
        return 2

    html = md_to_html(md_text, title)
    HTML(string=html, base_url=str(HERE)).write_pdf(str(out))
    print(f"md2pdf: wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
