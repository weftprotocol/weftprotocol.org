# weftprotocol.org

Source of the [Weft Protocol](https://weftprotocol.org) website and specifications.

The website is plain HTML5 and CSS: no JavaScript, no frameworks. GitHub Pages serves it from `docs/`.

## Layout

| Path | What it is |
| --- | --- |
| `src/**/*.md` | **Source of truth for the specifications** (Markdown) |
| `docs/` | The published site, served by GitHub Pages |
| `docs/spec/**/*.html` | Generated from `src/spec/**/*.md`. Do not edit by hand |
| `docs/index.html`, `docs/implementations/`, `docs/trademark/`, `docs/ns/` | Hand-written pages |
| `docs/assets/` | `site.css`, icons |
| `docs/CNAME`, `docs/.nojekyll` | Custom domain; turns off Jekyll |
| `tools/template.html` | Page template (header, footer) for generated pages |
| `generate.sh` | Converts `src/**/*.md` to `docs/**/*.html` |

`src/` mirrors the published paths: `src/spec/namespace/0.1/index.md` becomes `docs/spec/namespace/0.1/index.html`.

## Editing the specs

1. Edit the Markdown in `src/`.
2. Run `./generate.sh` (needs [pandoc](https://pandoc.org): `brew install pandoc`).
3. Commit both the Markdown and the generated HTML. GitHub Pages does no build, so the HTML must be committed.

Each Markdown file starts with a YAML block giving the page `title` and `description`. Link between pages by their relative `.md` path, for example `../../hosting/0.1/index.md`; the generator turns `.md` links into `.html`.

Published spec versions live at permanent URLs and are never rewritten once final; corrections go in a new version folder.

## Previewing

Links are relative, so `open docs/index.html` works straight from disk.

## License

Specifications are CC BY 4.0. See the footer of each page.
