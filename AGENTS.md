# Repository Guidelines

## Project Structure & Module Organization
This repository is a Rails 8 application. Core MVC code lives in `app/`, with controllers in `app/controllers`, models in `app/models`, and ERB views in `app/views`. Reusable UI is built with ViewComponent classes in `app/components` and matching templates such as `app/components/layout/app_shell_component.html.erb`. Hotwire code lives in `app/javascript`, especially Stimulus controllers under `app/javascript/controllers`. Configuration is in `config/`, database schema and migrations in `db/`, and automated tests in `test/`.

## Build, Test, and Development Commands
Use the project binstubs instead of global commands.

- `bin/setup`: install gems, prepare the SQLite database, clear logs/tmp, and optionally start the server.
- `bin/dev`: start the Rails server locally.
- `bin/rails db:prepare`: create or migrate the local database.
- `bin/rails test`: run the Minitest suite.
- `bin/ci`: run the full local CI flow defined in `config/ci.rb`.
- `bin/rubocop`: run Ruby style checks.
- `bin/brakeman`, `bin/bundler-audit`, `bin/importmap audit`: run security checks.

## Coding Style & Naming Conventions
Follow standard Rails conventions and the shared RuboCop profile from `rubocop-rails-omakase`. Use 2-space indentation in Ruby, ERB, CSS, and JavaScript. Keep class and module names in `CamelCase`, files in `snake_case`, controller classes ending in `Controller`, and ViewComponent classes ending in `Component`. Name Stimulus controllers `*_controller.js` and keep templates paired with their component class.

## Testing Guidelines
Tests use Minitest and live under `test/`. Name files `*_test.rb` and mirror the application structure where practical, for example `test/controllers/home_controller_test.rb`. Run `bin/rails test` before opening a PR. When changing setup, seeds, or security-sensitive code, run `bin/ci` so style, audits, tests, and seed replanting all pass together.

## Commit & Pull Request Guidelines
The current `master` branch has no commit history yet, so there is no established subject-line convention to copy. Use short, imperative commit titles such as `Add workspace shell component` and keep unrelated changes separate. PRs should include a clear summary, testing notes, linked issues when applicable, and screenshots for UI changes.

## Security & Configuration Tips
Do not commit secrets or edited credential files casually. Treat `config/master.key`, `config/credentials.yml.enc`, and local SQLite files under `storage/` as sensitive. Prefer environment-specific configuration over hard-coded values.
