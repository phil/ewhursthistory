# PLAN.md — Ewhurst History Society Website Rebuild

## Overview

A Rails 8.1 content site for a local history society. Public-facing pages display
society information, meetings, publications, and journal content. A protected admin
section allows authorised users to manage all content.

**Stack:** Rails 8.1 · PostgreSQL · Propshaft · Import Maps · Hotwire (Turbo + Stimulus) · Active Storage · Solid Cache/Queue/Cable · Heroku (deployment)

**Development:** Uses a devcontainer (`.devcontainer/`) with a PostgreSQL service container, matching the production database adapter. SQLite is not used in any environment.

---

## Data Models

### User
Multiple named admin accounts (one per webmaster). Uses the Rails 8 built-in
authentication generator (`rails generate authentication`), which produces `User`,
`Session`, and the associated controllers/views.

```
users
  name            string  not null
  email_address   string  not null, unique
  password_digest string  not null
  created_at / updated_at
```

No public-facing user accounts; all content is publicly readable.

---

### Page
Hierarchical content tree for all general site content (history articles, about
pages, links, etc.). Hierarchy is implemented with a self-referential `parent_id`
association — no third-party gem. Looked up by slug (derived from the URL path).

```
pages
  title       string   not null
  slug        string   not null
  parent_id   integer  FK → pages.id, null = root page
  body        text     (rich text via Lexxy — stored as HTML)
  published   boolean  default false
  position    integer  (for ordering siblings)
  created_at / updated_at

  # DB index: unique on [parent_id, slug] — slugs must be unique among siblings,
  # not globally. This allows /about/history and /great-war/history to coexist.
```

Rails associations on `Page`:
```ruby
belongs_to :parent, class_name: "Page", optional: true
has_many   :children, class_name: "Page", foreign_key: :parent_id,
           dependent: :destroy, inverse_of: :parent
scope      :roots,     -> { where(parent_id: nil) }
scope      :published, -> { where(published: true) }

validates :slug, uniqueness: { scope: :parent_id }
```

Pages are rendered by `PagesController#show` via a catch-all route. A single
view template handles all pages; child pages are linked from a sub-nav rendered
from `page.children.published.order(:position)`.

---

### Programme
Represents an academic year season (e.g. 2025–26). Groups a set of meetings.
Only one programme is "current" at a time.

```
programmes
  title       string   not null   (e.g. "Programme 2025–26")
  season_year integer  not null   (e.g. 2025, the start year of the Aug–Jul cycle)
  description text
  created_at / updated_at
```

Scopes:
- `.current` — programme where `season_year` equals the current academic year
  start (i.e. `Date.today.month >= 8 ? Date.today.year : Date.today.year - 1`)

---

### Event
An individual meeting, talk, AGM, or outing belonging to a `Programme`. The
model is named `Event`; views and UI refer to events as "Meetings" throughout.

```
events
  programme_id  integer  not null, FK → programmes
  title         string   not null
  description   text
  location      string
  held_on       date     not null
  starts_at     time
  event_type    string   default "meeting"  (meeting | outing | agm | other)
  created_at / updated_at
```

---

### Publication
Books and pamphlets produced by the society. Most have a price. Sold-out
publications are made available as a free PDF download.

```
publications
  title         string   not null
  author        string
  description   text     (rich text via Lexxy)
  published_on  date
  price_pence   integer  not null, default 0
  sold_out      boolean  not null, default false
  created_at / updated_at

  # Active Storage attachments:
  cover_image   has_one_attached
  document      has_one_attached   (PDF — only served when sold_out: true)
```

Display logic: if `sold_out` is false, show price and contact details to purchase.
If `sold_out` is true, show a download link to `document`.

---

### JournalEntry
A single entry (issue) of the society's regular journal. Each entry stores an
uploaded PDF.

```
journal_entries
  title         string   not null
  description   text     (rich text via Lexxy)
  published_on  date     not null
  created_at / updated_at

  # Active Storage:
  document      has_one_attached   (PDF — required)
```

---

## Controllers & Routing

```ruby
# Public
get  "/"                  => "home#index"
get  "/programme"         => "programme#index"    # current season
get  "/programme/:year"   => "programme#show"     # past season by season_year
get  "/publications"      => "publications#index"
get  "/publications/:id"  => "publications#show"
get  "/journal"           => "journal#index"
get  "/journal/:id"       => "journal#show"
get  "/*path"             => "pages#show"         # catch-all — must be last

# Admin
namespace :admin do
  root to: "dashboard#index"
  resources :users
  resources :pages
  resources :programmes do
    resources :events
  end
  resources :publications
  resources :journal_entries
end
```

The catch-all `/*path` route **must** be declared last in `routes.rb`.

### PagesController — nested path resolution

The catch-all delivers the full URL path as `params[:path]`, e.g. `"the-great-war/the-somme"`.
The controller splits this into segments and walks down the page tree one level at a time,
matching each segment against the slug of pages whose `parent_id` equals the previously
found page.

```ruby
class PagesController < ApplicationController
  def show
    page = resolve_path(params[:path])
    return not_found unless page && page.published?
    @page = page
  end

  private

  def resolve_path(path)
    segments = path.to_s.split("/").reject(&:blank?)
    return nil if segments.empty?

    current = nil
    segments.each do |segment|
      current = Page.find_by(slug: segment, parent_id: current&.id)
      return nil if current.nil?
    end
    current
  end

  def not_found
    render file: "public/404.html", status: :not_found, layout: false
  end
end
```

**Traversal rules:**
- First segment is matched against root pages (`parent_id: nil`)
- Each subsequent segment is matched against children of the previously resolved page
- Any segment that fails to match → 404
- A resolved page with `published: false` → 404 (unpublished pages are invisible to the public)
- An intermediate page in the path being unpublished does **not** block resolution of its
  children — only the final page's published state is checked (so editors can structure
  content while drafting)

**URL helper** — a `page_path` helper generates the correct nested path from a `Page` record
by walking up the parent chain:

```ruby
# app/helpers/pages_helper.rb
def page_path(page)
  segments = []
  node = page
  while node
    segments.unshift(node.slug)
    node = node.parent
  end
  "/" + segments.join("/")
end
```

---

## Navigation Structure

```
Home
├── Programme        → hardcoded link to ProgrammeController#index
├── Publications     → hardcoded link to PublicationsController#index
├── Journal          → hardcoded link to JournalController#index
│
└── (dynamic — top-level Pages with published: true, ordered by position)
    ├── The Great War
    ├── About Ewhurst
    │   ├── A Brief History of Ewhurst
    │   └── Old Houses
    └── Links
```

The layout queries `Page.roots.published.order(:position)` and appends them
after the three hardcoded links.

---

## Rich Text — Lexxy

Page bodies, publication descriptions, and journal entry descriptions use
[Lexxy](https://github.com/basecamp/lexxy) as the rich text editor (Trix
replacement from Basecamp). Content is stored as HTML in a plain `text` column
(no Action Text / `has_rich_text` association).

Integration steps (to be confirmed against Lexxy's gem/npm docs at build time):
- Add Lexxy to Import Maps or install via JS
- Render Lexxy editor in admin forms targeting the `body`/`description` text column
- Output stored HTML via `raw` in views (sanitised on save using `Rails::Html::SafeListSanitizer`)

---

## Admin Section

- Namespaced under `/admin`
- `Admin::BaseController < ApplicationController` enforces `before_action :require_authentication`
- All admin resource controllers inherit `Admin::BaseController`
- No third-party admin framework (no Administrate / ActiveAdmin)
- Plain CSS styling; Stimulus controllers for interactive elements (drag-to-reorder pages, image previews)
- Admin dashboard shows counts and links to each resource

### Admin Layout

The admin section uses a dedicated layout (`layouts/admin.html.erb`) separate from
the public layout. The page is divided into two regions:

```
┌─────────────────────────────────────────────┐
│  Admin header (site name + logged-in user)  │
├──────────────┬──────────────────────────────┤
│              │                              │
│   Left nav   │       Main content           │
│              │                              │
│  Dashboard   │  (index tables, forms,       │
│  Pages       │   show views, etc.)          │
│  Programme   │                              │
│  Publications│                              │
│  Journal     │                              │
│  Users       │                              │
│              │                              │
├──────────────┴──────────────────────────────┤
│  Footer                                     │
└─────────────────────────────────────────────┘
```

Implemented with CSS grid on the admin `<body>` or a wrapper element:

```css
.admin-layout {
  display: grid;
  grid-template-columns: 16rem 1fr;
  grid-template-rows: auto 1fr auto;
  min-height: 100vh;
}

.admin-sidebar { grid-row: 2; grid-column: 1; }
.admin-main    { grid-row: 2; grid-column: 2; }
```

The sidebar collapses to a top bar on small screens (single-dyno admin use is
assumed to be desktop, but the layout should not break on smaller viewports).

---

## HTML Structure

All public pages use a single application layout built with semantic HTML5 elements.
No `<div>` wrappers where a semantic element is appropriate.

```html
<!DOCTYPE html>
<html lang="en">
<head>...</head>
<body>

  <header>
    <a href="/" class="site-title">Ewhurst History Society</a>
    <nav aria-label="Primary navigation">
      <ul>
        <li><a href="/programme">Programme</a></li>
        <li><a href="/publications">Publications</a></li>
        <li><a href="/journal">Journal</a></li>
        <!-- dynamic Page roots appended here -->
      </ul>
    </nav>
  </header>

  <main>
    <!-- HomeController -->
    <section aria-labelledby="hero-heading">...</section>

    <!-- PagesController — a page with children -->
    <article>
      <header><h1>About Ewhurst</h1></header>
      <div class="body-content"><!-- Lexxy HTML --></div>
      <nav aria-label="Section navigation">
        <ul><!-- child page links --></ul>
      </nav>
    </article>

    <!-- ProgrammeController -->
    <section aria-labelledby="programme-heading">
      <h1 id="programme-heading">Programme 2025–26</h1>
      <ol>
        <li>
          <article class="meeting">
            <time datetime="2025-09-18">18 September 2025</time>
            <h2>Meeting title</h2>
            <p>Location</p>
          </article>
        </li>
      </ol>
    </section>

    <!-- PublicationsController -->
    <section aria-labelledby="publications-heading">
      <h1 id="publications-heading">Publications</h1>
      <ul class="publication-list">
        <li>
          <article class="publication">
            <figure><img src="..." alt="Cover of ..."></figure>
            <h2>Title</h2>
            <p>Author · £X.XX</p>
          </article>
        </li>
      </ul>
    </section>
  </main>

  <footer>
    <p>&copy; Ewhurst History Society</p>
  </footer>

</body>
</html>
```

Rules:
- `<header>` / `<footer>` at page level; also permitted inside `<article>` / `<section>` for local headings
- `<main>` contains one primary content region per page
- `<article>` for self-contained content (a meeting, a publication, a page entry)
- `<section>` for thematic groupings within `<main>`; always has a heading
- `<nav>` with a descriptive `aria-label` for each navigation landmark
- `<time datetime="...">` for all dates and times
- `<figure>` / `<figcaption>` for images with captions

---

## Assets

- **Propshaft** — asset serving
- **Import Maps** — JS without a bundler
- **Hotwire** (Turbo + Stimulus) — navigation and interactivity
- **Plain CSS** — no preprocessor, no framework
- Shared component styles are defined once and used by both public and admin layouts

### CSS File Structure

Styles are split into three files to maximise sharing between public and admin layouts:

```
app/assets/stylesheets/
  base.css          # fonts, custom properties, reset, layout utilities, shared components
  application.css   # public layout — imports base.css, adds public-specific styles
  admin.css         # admin layout — imports base.css, adds admin sidebar/grid styles
```

`base.css` contains everything that can be shared: typography, colour tokens, spacing,
form elements, buttons, tables, flash messages, and any component that appears in both
contexts. Neither layout duplicates these rules.

Each layout's HTML `<head>` references only its own stylesheet:
- Public layout → `stylesheet_link_tag "application"`
- Admin layout  → `stylesheet_link_tag "admin"`

Both stylesheets begin with `@import "base.css"`.

### CSS Scaffold

`base.css` is structured in the following layers, in order:

```css
/* ============================================================
   1. FONTS
   ============================================================ */

@font-face {
  font-family: "Heading Font";
  src: url("/assets/fonts/heading-font.woff2") format("woff2");
  font-weight: 400 700;
  font-style: normal;
  font-display: swap;
}

@font-face {
  font-family: "Body Font";
  src: url("/assets/fonts/body-font.woff2") format("woff2");
  font-weight: 400 700;
  font-style: normal italic;
  font-display: swap;
}

/* ============================================================
   2. CUSTOM PROPERTIES
   ============================================================ */

:root {
  /* Typography */
  --font-heading: "Heading Font", Georgia, serif;
  --font-body:    "Body Font", Georgia, serif;
  --font-mono:    ui-monospace, monospace;

  --text-base:  1rem;       /* 16px */
  --text-sm:    0.875rem;
  --text-lg:    1.125rem;
  --text-xl:    1.5rem;
  --text-2xl:   2rem;
  --text-3xl:   2.75rem;

  --leading-tight:  1.2;
  --leading-normal: 1.6;

  /* Colour palette */
  --colour-bg:         #ffffff;
  --colour-text:       #1a1a1a;
  --colour-text-muted: #5a5a5a;
  --colour-border:     #d4d4d4;
  --colour-accent:     #5c3d1e;   /* placeholder — adjust to brand */
  --colour-accent-alt: #8a6240;

  /* Spacing scale */
  --space-xs:  0.25rem;
  --space-sm:  0.5rem;
  --space-md:  1rem;
  --space-lg:  1.5rem;
  --space-xl:  2.5rem;
  --space-2xl: 4rem;

  /* Layout */
  --content-width: 75rem;   /* 1200px */
  --content-padding: var(--space-md);
}

/* ============================================================
   3. RESET / BASE
   ============================================================ */

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

html { font-size: 100%; -webkit-text-size-adjust: 100%; }

body {
  font-family: var(--font-body);
  font-size: var(--text-base);
  line-height: var(--leading-normal);
  color: var(--colour-text);
  background: var(--colour-bg);
}

img, video { max-width: 100%; height: auto; display: block; }
a { color: inherit; }

/* ============================================================
   4. LAYOUT UTILITIES
   ============================================================ */

.container {
  max-width: var(--content-width);
  margin-inline: auto;
  padding-inline: var(--content-padding);
}

/* ============================================================
   5. COMPONENTS
   (header, nav, main, article, footer, etc.)
   ============================================================ */

/* ... component styles added here as the site is built ... */

/* ============================================================
   6. MEDIA QUERIES
   ============================================================ */

/* Tablet — 48rem / 768px */
@media (min-width: 48rem) {
  :root {
    --content-padding: var(--space-lg);
    --text-base: 1.0625rem;
  }

  /* ... tablet overrides ... */
}

/* Desktop — 75rem / 1200px */
@media (min-width: 75rem) {
  :root {
    --content-padding: var(--space-xl);
    --text-base: 1.125rem;
  }

  /* ... desktop overrides ... */
}

/* Wide — 90rem / 1440px */
@media (min-width: 90rem) {
  /* ... wide-screen refinements ... */
}

/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; }
}

/* Print */
@media print {
  header nav, footer { display: none; }
  body { font-size: 12pt; color: #000; }
  a[href]::after { content: " (" attr(href) ")"; }
}
```

Font files (`.woff2`) are placed in `app/assets/fonts/` and served by Propshaft.
Actual typeface choices to be decided; the scaffold above uses placeholder names.

---

## Authentication

```bash
rails generate authentication
```

Adds `name` column to the generated `User` migration. Seeds one initial admin
user in `db/seeds.rb`.

---

## File Uploads

Active Storage:
- Development: `local` disk adapter
- Production: cloud adapter (e.g. S3) configured in `config/storage.yml` via environment variables

---

## Seeds

`db/seeds.rb` provides a full set of realistic development data. Run with `rails db:seed`.
Seeds are idempotent — each record is found-or-created so the file can be re-run safely.
Active Storage attachments (cover images, PDFs) are **not** seeded at this stage.

### Users

```ruby
User.find_or_create_by!(email_address: "admin@ewhursthistory.org.uk") do |u|
  u.name     = "Head Webmaster"
  u.password = "password"
end

User.find_or_create_by!(email_address: "editor@ewhursthistory.org.uk") do |u|
  u.name     = "Second Webmaster"
  u.password = "password"
end
```

### Pages

Seeded to match the intended navigation structure. `find_or_create_by!` on `[slug, parent_id]`.

```
Root pages (parent_id: nil)
  position 1 — "The Great War"         slug: "the-great-war"
    position 1 — "The Somme"           slug: "the-somme"
    position 2 — "Local Regiments"     slug: "local-regiments"
    position 3 — "Roll of Honour"      slug: "roll-of-honour"

  position 2 — "About Ewhurst"         slug: "about-ewhurst"
    position 1 — "A Brief History"     slug: "a-brief-history"
    position 2 — "Old Houses"          slug: "old-houses"
    position 3 — "The Church"          slug: "the-church"

  position 3 — "Links"                 slug: "links"
```

All pages seeded with `published: true` and a short placeholder `body` (a paragraph
of lorem ipsum so views render without empty content).

### Programmes & Events

Two programmes — one past, one current (based on the Aug–Jul academic year cycle).

```ruby
# Past programme — 2024–25
past = Programme.find_or_create_by!(season_year: 2024) do |p|
  p.title = "Programme 2024–25"
end

[
  { title: "Annual General Meeting",       held_on: "2024-09-19", meeting_type: "agm",     location: "Village Hall" },
  { title: "The History of Ewhurst Mill",  held_on: "2024-10-17", meeting_type: "meeting", location: "Village Hall" },
  { title: "Autumn Outing — Guildford",    held_on: "2024-11-09", meeting_type: "outing",  location: "Guildford" },
  { title: "Christmas Social",             held_on: "2024-12-19", meeting_type: "meeting", location: "Village Hall" },
  { title: "New Year Lecture",             held_on: "2025-01-16", meeting_type: "meeting", location: "Village Hall" },
  { title: "Old Maps of Surrey",           held_on: "2025-02-20", meeting_type: "meeting", location: "Village Hall" },
  { title: "Spring Outing — Dorking",      held_on: "2025-04-12", meeting_type: "outing",  location: "Dorking" },
  { title: "Members' Evening",             held_on: "2025-05-15", meeting_type: "meeting", location: "Village Hall" },
].each { |attrs| past.events.find_or_create_by!(held_on: attrs[:held_on]) { |e| e.assign_attributes(attrs) } }

# Current programme — 2025–26
current = Programme.find_or_create_by!(season_year: 2025) do |p|
  p.title = "Programme 2025–26"
end

[
  { title: "Annual General Meeting",           held_on: "2025-09-18", meeting_type: "agm",     location: "Village Hall" },
  { title: "Surrey in the First World War",    held_on: "2025-10-16", meeting_type: "meeting", location: "Village Hall" },
  { title: "Autumn Outing — Haslemere",        held_on: "2025-11-08", meeting_type: "outing",  location: "Haslemere" },
  { title: "Christmas Social",                 held_on: "2025-12-18", meeting_type: "meeting", location: "Village Hall" },
  { title: "Farming in the Weald",             held_on: "2026-01-15", meeting_type: "meeting", location: "Village Hall" },
  { title: "Ewhurst Place and Its Owners",     held_on: "2026-02-19", meeting_type: "meeting", location: "Village Hall" },
  { title: "Spring Outing — TBC",              held_on: "2026-04-18", meeting_type: "outing",  location: "TBC" },
  { title: "Members' Evening",                 held_on: "2026-05-21", meeting_type: "meeting", location: "Village Hall" },
].each { |attrs| current.events.find_or_create_by!(held_on: attrs[:held_on]) { |e| e.assign_attributes(attrs) } }
```

### Publications

A mix of priced and sold-out titles (no file attachments yet).

```ruby
[
  { title: "A History of Ewhurst",              author: "J. R. Smith",    published_on: "2010-06-01", price_pence: 800,  sold_out: false },
  { title: "The Mills of the Weald",            author: "P. A. Brown",    published_on: "2005-03-01", price_pence: 500,  sold_out: true  },
  { title: "Ewhurst in the Great War",          author: "Society Members", published_on: "2014-11-01", price_pence: 1000, sold_out: false },
  { title: "Old Houses of Ewhurst Parish",      author: "M. T. Clarke",   published_on: "1998-01-01", price_pence: 300,  sold_out: true  },
  { title: "The Church of St Peter & St Paul",  author: "Society Members", published_on: "2018-04-01", price_pence: 400,  sold_out: false },
].each { |attrs| Publication.find_or_create_by!(title: attrs[:title]) { |p| p.assign_attributes(attrs) } }
```

### Journal Entries

```ruby
[
  { title: "The Greensand Way Through Ewhurst", published_on: "2024-06-01" },
  { title: "Farming Life in Victorian Surrey",   published_on: "2023-12-01" },
  { title: "The Brickworks of the Weald",        published_on: "2023-06-01" },
  { title: "Ewhurst Inns and Their Histories",   published_on: "2022-12-01" },
  { title: "The Domesday Survey and Ewhurst",    published_on: "2022-06-01" },
].each { |attrs| JournalEntry.find_or_create_by!(title: attrs[:title]) { |j| j.assign_attributes(attrs) } }
```

---

## Deployment

Heroku. The SQLite database must be replaced with **PostgreSQL** for production
(SQLite's ephemeral filesystem is wiped on every Heroku dyno restart).

- **Database:** `pg` gem throughout all environments; Heroku Postgres add-on in production. The devcontainer provides a PostgreSQL service container for development and test, so no adapter switching is needed.
- **Active Storage:** files stored on S3 (or compatible); configure `config/storage.yml`
  with credentials via Heroku config vars. The `aws-sdk-s3` gem is required.
- **Background jobs:** Solid Queue is not suitable for Heroku (requires a persistent
  database-backed queue on a separate worker dyno). Use **Solid Queue on Postgres**
  or replace with **Delayed Job** (pg-backed) or simply run Active Storage analysis
  inline if job volume is low.
- **Caching:** Solid Cache backed by Postgres, or use Heroku's Redis add-on with
  the `redis-rails` cache store.
- **Procfile:** defines `web` and optionally `worker` dynos.
- **Kamal:** remove — not used for Heroku deployments.
- **Config vars** required in production:
  `DATABASE_URL`, `SECRET_KEY_BASE`, `RAILS_MASTER_KEY`,
  AWS S3 credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_BUCKET`, `AWS_REGION`)

```
# Procfile
web: bundle exec puma -C config/puma.rb
```
