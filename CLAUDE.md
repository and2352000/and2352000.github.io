# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hugo-based personal blog hosted on GitHub Pages at `aaron.cryptobrother.net`. The theme (`themes/mini`) is a git submodule pointing to a personal fork.

## Common Commands

```bash
make dev                                              # Run local dev server at http://localhost:1313
hugo server                                           # Same as above
hugo --minify                                         # Build production site to /public
hugo new content content/posts/<post-name>.md         # Create new post from archetype
```

## Deployment

Pushing to `main` triggers GitHub Actions ([.github/workflows/gh-pages.yml](.github/workflows/gh-pages.yml)), which builds with `hugo --minify` and deploys `./public` to GitHub Pages. No manual deployment needed.

## Content Structure

- Blog posts live in [content/posts/](content/posts/) as either single `.md` files or folders with `index.md` (for posts with accompanying images/assets)
- Posts use front matter from [archetypes/posts.md](archetypes/posts.md): `title`, `date`, `draft`, `category`, `tags`
- New posts are created with `draft: true` by default — set to `false` to publish

## Configuration

- [config.yaml](config.yaml) — site-wide settings (baseURL, title, theme, analytics)
- [static/CNAME](static/CNAME) — custom domain (`aaron.cryptobrother.net`)
- `public/` is git-ignored (CI-generated), except `public/CNAME` and `public/.gitkeep`

## Theme

The `themes/mini` submodule points to `https://github.com/and2352000/hugo-theme-mini.git`. When cloning, use `--recurse-submodules` or run `git submodule update --init` to fetch the theme.
