# Buzzy's Bar: project brief

Cocktail recipe web app by Alejandro Cortes, live at `buzzysbar.com`. A ground-up rewrite of an earlier version, started January 2025 to use Rails 8 and current practices (influenced by *Agile Web Development with Rails* and Sandi Metz's *Practical Object-Oriented Design*). Still in progress. It is also a featured project on Alejandro's portfolio (`alejandrocortes.dev`), so finished work should be easy to describe in a write-up.

## How we work

Alejandro is a recent CS graduate whose strongest stack is Ruby on Rails. Keep code idiomatic Rails ("the Rails way" first) and explain non-obvious choices briefly. Work in small steps and check in between them. Do not add gems, npm packages, or a front-end framework without asking. Never deploy (`bin/kamal ...`) or touch the production server without asking first.

## Stack

- Ruby 3.4.2 (`.ruby-version`), Rails 8.1 (`config.load_defaults 8.1`)
- PostgreSQL 17
- Hotwire (Turbo, Stimulus), importmap (no JS bundler), Propshaft
- Tailwind CSS v4 via `tailwindcss-rails`; theme and custom colors live in `app/assets/tailwind/application.css`
- Active Storage (images, `image_processing`), Action Text (rich text)
- Solid Queue, Solid Cache, Solid Cable (no Redis)
- Authentication from the Rails 8 generator (`Session`, `Current`, `has_secure_password`)
- Minitest: model, controller, and system tests

## Commands

- `bin/dev`: run the app locally (Rails server plus Tailwind watcher, from `Procfile.dev`). `docker-compose.yml` can also run the app with a Postgres container.
- `bin/rails test` and `bin/rails test:system`: run tests
- `bin/ci`: runs every check locally (setup, RuboCop, Brakeman, importmap audit, tests, seeds, system tests), as listed in `config/ci.rb`. GitHub CI (`.github/workflows/ci.yml`) runs the same checks.
- `bin/rails db:seed`: sample drinks. Note: the seed file starts with `Beverage.delete_all`.

Run `bin/ci` before calling a change done.

In system tests, use the helpers in `test/application_system_test_case.rb` (`sign_in_as`, `enter`, `press`, `accept_confirm_dialog`) instead of `fill_in`, `click_on` and `accept_confirm`. Headless Chrome intermittently drops or delays native input, locally and in CI, so those helpers act through the DOM. CI runs on `ubuntu-24.04`, since `ubuntu-latest` has no prebuilt Ruby 3.4.2.

## Deployment

- Kamal 2 to a single Hetzner server (`config/deploy.yml`). Image builds on the server itself (remote builder over SSH), cached in Docker Hub.
- Containers: web, a job runner (`solid_queue:start`), and Postgres as a Kamal accessory. kamal-proxy handles HTTPS for `buzzysbar.com` and `www.buzzysbar.com`.
- The app reaches Postgres by its container name, `buzzysbar-postgres` (`POSTGRES_HOST`), on the `kamal` Docker network. Don't use a container IP: it changes when the container restarts, which took the site down in October 2026.
- Deploy secrets (`KAMAL_REGISTRY_PASSWORD`, `POSTGRES_PASSWORD`) are read from the macOS Keychain under the account `buzzysbar`; see `.kamal/secrets`.
- Uploads persist on the `buzzysbar_storage` volume.
- Secrets come from `.kamal/secrets`. Never commit secret values or `config/master.key`.

## The product

**`VISION.md` is the source of truth for where the app is going.** It replaces the original curator/member spec in `README.md`. In short: a private logbook of tiki drinks tried by a changing group of family and friends, at bars and at home. It's built around occasions (place, date, who came), tastings of drinks (optionally using a recipe), per-person ratings, and photos. It's private by default, with chosen items made public and a demo account for portfolio visitors. Follow the roadmap in `VISION.md`; don't build the dropped features (roles, collections, comments, public sign-up).

- Keep logging fast: someone at a bar who knows only a drink's name must be able to log it in about 15 seconds. Ratings, photos and notes stay optional.
- Don't name a model `Session` (the authentication generator uses it). A `Person` is separate from a login `User`.
- Never make photos of people, or recipes copied from books, public.

### Built so far

- `Beverage`: title (unique), featured image, and rich-text description, ingredients, and instructions, all required. The index refreshes live via Turbo broadcasts (`broadcast_refresh_later_to "beverages"`). It becomes `Recipe` (belonging to a `Drink`) in phase 4; don't strip it down before then.
- `User`: name and email (both unique), password, sessions. Login, logout, and password reset. No public sign-up; accounts are invite-only.
- Phase 1 so far (branch `phase-1-logbook`): `Person` (optionally linked to a `User`), `Place` (bar or home), `Occasion` with `Attendance`, `Drink` (a unique name plus an optional description), and `Tasting` (a drink at an occasion) with per-person `Rating`s (1–5 in half points, only by people who came). Records with history (people, places, drinks) can't be deleted. The old `Review` model was removed.
- Photos: occasions have many; tastings have one, and so do beverages (`featured_image`). Rules live in `PhotoAttachments` (JPEG, PNG, GIF, WebP, HEIC; 25 MB max), and `:thumb`/`:large` variants convert to JPEG. Resizing needs libvips: it's in the Dockerfile and in GitHub CI's packages, and locally it's `brew install vips`. System tests do process variants, since the browser loads the images.
- Logging: `DrinkLog` (`app/models/drink_log.rb`, a form object) powers "Log a drink" at `/log/new`. Only drink and place names are required. It finds or creates the place, drink, people and the occasion at that place on that date, then adds the tasting. Ratings are added afterwards via "Rate or edit".
- Logbooks: every `User`, `Person`, `Place`, `Drink` and `Occasion` belongs to a `Logbook` (the family's, and later the demo's). Controllers and forms reach records through `Current.logbook` (e.g. `Current.logbook.occasions.find`), so another logbook's records are a 404. `SameLogbookValidator` rejects ids that link across logbooks. Drink names are unique per logbook. `test/controllers/logbook_isolation_test.rb` covers it.
- Demo: `DemoLogbook` (`app/models/demo_logbook.rb`) builds made-up people, bars, occasions, tastings and ratings for the demo user (`demo@buzzysbar.com`, random password). `DemoLogbook.reset!` clears the demo logbook and rebuilds it, keeping the same user; dates count back from today. `db/seeds.rb` runs it, and `ResetDemoJob` runs it every night at 4 AM Central (`config/recurring.yml`, production only), also signing out demo sessions older than a day. "Try the demo" on the sign-in page (`DemosController`, `POST /demo`) signs visitors in as the demo user, building the demo if it's missing. Demo visitors are anonymous, so `prevent_in_demo` (`ApplicationController`) blocks them from changing recipes or users, and photo uploads are off; `demo?` is a helper for views.
- Public sharing (phase 3) so far: everything is private until published, one item at a time. A drink with `published` checked gets a public ranking at `/rankings/:id` (`RankingsController`, no login). Public views are separate from the private ones and show only the bar (or "At home"), the month and average scores: never people's names, notes or photos. Demo visitors can't publish.
- The home page is the occasions list. Browsing beverages (shown as "Recipes") is public; everything else requires login.
- The time zone is Central (`config.time_zone`), so late-night logs get the right date.

### Known issues

None right now.
