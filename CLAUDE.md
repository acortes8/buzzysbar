# Buzzy's Bar: project brief

Cocktail recipe web app by Alejandro Cortes, live at `buzzysbar.com`. A ground-up rewrite of an earlier version, started January 2025 to use Rails 8 and current practices (influenced by *Agile Web Development with Rails* and Sandi Metz's *Practical Object-Oriented Design*). Still in progress. It is also a featured project on Alejandro's portfolio (`alejandrocortes.dev`), so finished work should be easy to describe in a write-up.

## How we work

Alejandro is a recent CS graduate whose strongest stack is Ruby on Rails. Keep code idiomatic Rails ("the Rails way" first) and explain non-obvious choices briefly. Work in small steps and check in between them. Do not add gems, npm packages, or a front-end framework without asking. Never deploy (`bin/kamal ...`) or touch the production server without asking first.

## Stack

- Ruby 3.4.2 (`.ruby-version`), Rails 8.0
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
- `bin/rubocop`, `bin/brakeman`, `bin/importmap audit`: the same checks CI runs (`.github/workflows/ci.yml`)
- `bin/rails db:seed`: sample drinks. Note: the seed file starts with `Beverage.delete_all`.

Run the tests and RuboCop before calling a change done.

## Deployment

- Kamal 2 to a single Hetzner server (`config/deploy.yml`). Image builds on the server itself (remote builder over SSH), cached in Docker Hub.
- Containers: web, a job runner (`solid_queue:start`), and Postgres as a Kamal accessory. kamal-proxy handles HTTPS for `buzzysbar.com` and `www.buzzysbar.com`.
- The app reaches Postgres by container IP (`POSTGRES_HOST`), because the hostname did not resolve.
- Uploads persist on the `buzzysbar_storage` volume.
- Secrets come from `.kamal/secrets` (`KAMAL_REGISTRY_PASSWORD`, `RAILS_MASTER_KEY`, `POSTGRES_PASSWORD`). Never commit secret values or `config/master.key`.

## The product

**`VISION.md` is the source of truth for where the app is going.** It replaces the original curator/member spec in `README.md`. In short: a private logbook of tiki drinks tried by a changing group of family and friends, at bars and at home. It's built around occasions (place, date, who came), tastings of drinks (optionally using a recipe), per-person ratings, and photos. It's private by default, with chosen items made public and a demo account for portfolio visitors. Follow the roadmap in `VISION.md`; don't build the dropped features (roles, collections, comments, public sign-up).

- Keep logging fast: someone at a bar who knows only a drink's name must be able to log it in about 15 seconds. Ratings, photos and notes stay optional.
- Don't name a model `Session` (the authentication generator uses it). A `Person` is separate from a login `User`.
- Never make photos of people, or recipes copied from books, public.

### Built so far

- `Beverage`: title (unique), featured image, and rich-text description, ingredients, and instructions, all required. The index refreshes live via Turbo broadcasts (`broadcast_refresh_later_to "beverages"`). It will be repurposed as `Drink`/`Recipe`.
- `User`: name and email (both unique), password, sessions. Login, logout, and password reset. No public sign-up; accounts are invite-only.
- `Review` (uncommitted as of 2026-10-30): title, body, rating 1–5, belongs to a user. Routes are limited to `index`, `show`, `new` and `create`. It will be repurposed as `Tasting`/`Rating`.
- Browsing beverages (`index`, `show`) is public; everything else requires login.

### Known issues

- `Beverage#acceptable_image` is defined but never registered (needs `validate :acceptable_image`). It also rejects HEIC, which iPhone photos use by default.
- `UsersController#create` has a leftover `puts` debug line.
- `README.md` is still the Rails default plus the old spec, and it lists Ruby 3.4.1.
