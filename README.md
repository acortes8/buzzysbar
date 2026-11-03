# Buzzy's Bar

A private logbook of tiki drinks tried by family and friends, at bars and at
home: occasions (place, date, who came), the drinks tasted, per-person ratings,
and photos. Live at [buzzysbar.com](https://buzzysbar.com).

Where the app is going is described in [`VISION.md`](VISION.md).

## Stack

- Ruby 3.4.2, Rails 8.1, PostgreSQL 17
- Hotwire (Turbo, Stimulus), importmap, Propshaft, Tailwind CSS v4
- Active Storage and Action Text
- Solid Queue, Solid Cache, Solid Cable
- Deployed with Kamal 2

## Running locally

Install libvips (`brew install vips`) for image resizing, then:

```sh
bin/setup      # install gems, prepare the database
bin/dev        # Rails server plus the Tailwind watcher
```

`docker-compose.yml` can also run the app with a Postgres container.
`bin/rails db:seed` loads sample recipes (it clears existing ones first).

## Tests

```sh
bin/rails test          # model and controller tests
bin/rails test:system   # system tests (headless Chrome)
bin/ci                  # everything CI runs: RuboCop, Brakeman, audits, tests, seeds
```
