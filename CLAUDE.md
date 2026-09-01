# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

**Repertoria** — a Rails 8.1 app that builds a personalized 3-opening chess repertoire for
players rated ~300–1000 ELO. A visitor enters a Chess.com username; the app pulls their recent
Rapid games from the Chess.com public API, computes ELO and win rates in Ruby, then asks an LLM
to recommend one opening for White, one for Black vs 1.e4, and one for Black vs 1.d4 — chosen
only from the openings seeded in the database. UI, the LLM system prompt, and domain vocabulary
are all in **French**.

Ruby 3.3.5, PostgreSQL, importmap + Hotwire (Turbo/Stimulus), Bootstrap 5.3 via
sassc/sprockets, `simple_form`, Devise. Deploy is Kamal + Docker + Thruster. Solid
Queue/Cache/Cable are DB-backed.

## Commands

```bash
bin/setup                 # install gems, prepare DB (pass --skip-server to not boot)
bin/dev                   # run the app (thin wrapper over `bin/rails server`)
bin/rails db:seed         # (re)load the 9 openings; seeds.rb does Opening.destroy_all first
bin/rails db:seed:replant # reset + reseed

bin/rails test                              # all tests (parallelized, fixtures :all)
bin/rails test test/models/game_test.rb     # one file
bin/rails test test/models/game_test.rb:12  # one test by line
bin/rails test:system                       # Capybara + Selenium

bin/rubocop               # lint (rubocop-rails-omakase + .rubocop.yml overrides); -a to autocorrect
bin/brakeman             # static security scan
bin/bundler-audit        # gem CVE audit
bin/importmap audit      # JS dependency audit

bin/ci                   # runs the whole pipeline above; steps defined in config/ci.rb
```

Requires `OPENAI_API_KEY` in `.env` (loaded by `dotenv-rails`, wired in
`config/initializers/ruby_llm.rb`). There is no GitHub Actions CI — only Dependabot.

## Architecture

### The analysis pipeline (the core of the app)

`PagesController#analyse` (`GET /analyse?username=`) is the entry point:

1. `Game.fetch_from_chess_com(username, 50)` — walks the player's Chess.com monthly archives
   newest-first via `Net::HTTP`, keeps only `time_class == "rapid"`.
2. `Game.player_elo` and `Game.win_rates` — plain Ruby aggregation over that game list.
3. `DataAnalyzer.new.call(games, elo, winrate)` — see below.
4. Renders `openings/index` (the dashboard). The whole result bundle is cached in
   `Rails.cache` under `analysis/<username>` for 1 hour, and `session[:username]` is stored.
5. Guard rails: unknown player or `< 10` games → redirect to root with a French alert.

`OpeningsController#repertoire` (`GET /openings/repertoire`) re-runs steps 1–3 from scratch
(**not cached**) using `session[:username]`, then computes per-opening play counts / win rates
via `Game.opening_stats`. It breaks if `/analyse` hasn't been hit first in the session.

### `DataAnalyzer#call`

- The large French `SYSTEM_PROMPT` constant at the top of `app/models/data_analyzer.rb` is the
  contract with the model: return strict JSON with `white` / `black_vs_e4` / `black_vs_d4`
  entries, each picking an `opening_recommended_id` **from the catalog we send it**.
- Builds that catalog from the `openings` table grouped by `color` / `against`, sends
  `{elo, winrate, games, openings}` as JSON to `RubyLLM.chat` (`ruby_llm` gem, OpenAI provider),
  `JSON.parse`s the reply, then re-hydrates each recommended opening's real `name` and
  `suite_de_coups` from the DB by ID (the model is told not to invent names/moves).

### Data model notes

- `Opening` is **seed-only** — no CRUD UI. Fields: `name`, `suite_de_coups` (string; seeds
  store an array literal), `color` (`"white"`/`"black"`), `against` (`"e4"`/`"d4"`/`nil`),
  `video_url`, `image`, `description`. `db/seeds.rb` defines 9 openings.
- `Game` and `DataAnalyzer` are `ApplicationRecord` subclasses but used as service objects.
  Their tables (`games`, `data_analyzers`) exist but the main flow does not persist to them;
  `data_analyzers.updated_at` is only read on `openings#index` for a "last update" timestamp.
- `User` (Devise: database_authenticatable, registerable, recoverable, rememberable,
  validatable) `has_many :games`. Global `authenticate_user!` is **commented out** in
  `ApplicationController` — the app is currently open. `ApplicationController` stores the last
  non-Devise GET path for post-login redirect.

### Views / front-end

- `openings#show` renders tab content lazily: member routes `description`, `explanation`,
  `resources` each `render partial:` the matching `app/views/openings/_*.html.erb`. A
  `tab_content` action/partial exists in the controller but has no route.
- Stimulus `accordion_controller.js` drives collapsibles (`is-open` / `is-rotated` classes).
- SCSS is organized under `app/assets/stylesheets/{config,components,pages}` and imported from
  `application.scss`.

## Gotchas

- `/analyse` and `/openings/repertoire` make **synchronous live HTTP calls** to Chess.com and
  OpenAI inside the request cycle — slow, and failing when either service is down or the key is
  missing. Nothing is stubbed.
- The checked-in test files are all empty generator stubs.
- The file at the repo root literally named `is.dig("white", "opening")` is an accidental IRB
  output dump — safe to delete.
- Current branch is `LLMToday`; recent history is messy WIP around the LLM integration.
