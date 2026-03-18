# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Setup
bin/setup               # Create DB and load schema

# Development
rails s                 # Start dev server (Puma)

# Testing
bin/rspec               # Run full test suite
bin/rspec spec/models/page_spec.rb  # Run a single spec file
```

## Architecture

**Ewhurst History Society** — a Rails 5.2 content site backed by PostgreSQL, deployed to Heroku via Travis CI.

### Routing
The catch-all route `*path → pages#show` means almost every URL is handled by `PagesController`, which looks up pages by their slug/path. The root (`/`) goes to `BaseController#index`.

### Core Models
- **Page** — hierarchical content tree using the **Ancestry** gem. Has a `template` field that controls which view partial is rendered (`:default`, `:world_war_one_index`, `:world_war_one_page`, `:journal_index`). Pages have many `Attachment`s and `Image`s.
- **Post** — covers News, Meetings, and Events (scoped via a `type`-like mechanism). The `.programme` scope returns the current academic year's meetings.
- **Publication** — books/pamphlets with cover images and downloadable files.
- **Attachment** / **Image** — files uploaded via **CarrierWave** to AWS S3 (using the `fog` gem).

### Admin
ActiveAdmin + Devise at `/admin`. `AdminUser` is the only authentication model.

### Assets
Traditional Rails asset pipeline (Sprockets): SCSS stylesheets, CoffeeScript JS, jQuery. No Webpack or Import Maps.

### Key Environment Variables
Production requires: `DATABASE_URL`, `SECRET_KEY_BASE`, AWS S3 credentials (via CarrierWave/Fog config), `POSTMARK_API_TOKEN`, `NEW_RELIC_LICENSE_KEY`.

### URL Rewrites
`config/application.rb` configures `rack-rewrite` rules to redirect legacy URLs to their new equivalents.
