# whity-org/.github

Shared CI for Whity repositories. The repository is public, so every Whity
repository, public or private, can call these workflows.

## Reusable workflows

### `php-tests.yml`: PHP tests

Installs PHP 8.4 (refusing anything older than 8.4.27), runs composer
install, an optional set-up, optional PHPStan and the tests, optionally beside
PostgreSQL.

```yaml
jobs:
  postgres:
    uses: whity-org/.github/.github/workflows/php-tests.yml@main
    with:
      name: Tests (Postgres)
      postgres: true
      postgres-db: myapp_test
      postgres-user: myapp
      env: |
        DB_CONNECTION=pgsql
        DB_HOST=127.0.0.1
        DB_DATABASE=myapp_test
        DB_USERNAME=myapp
        DB_PASSWORD=ci-only-not-a-secret
      setup: |
        cp .env.example .env
        php artisan key:generate --ansi
      test-command: php artisan test --without-tty
```

| Input | Default | What it does |
|---|---|---|
| `name` | `Tests` | The job's name. |
| `php-version`, `php-floor` | `8.4`, `8.4.27` | The PHP minor version, and the oldest patch accepted. |
| `extensions` | `mbstring, pdo_sqlite, pdo_pgsql, pgsql, zip, pcntl, sodium` | PHP extensions. |
| `checkout-path`, `working-directory` | `.`, `.` | Where your repository is checked out, and where composer and the tests run. |
| `core-sdk`, `core-ref`, `core-sparse` | `false`, `develop`, `sdk` | Check out whity-core beside it at `./whity-core`, for a Composer path repository on its SDK. An empty `core-sparse` checks out all of it. |
| `composer-args` | `--no-interaction --no-progress --prefer-dist` | Arguments for composer install. |
| `setup` | none | Shell commands run after composer install. |
| `test-command` | `vendor/bin/phpunit` | The test command. |
| `phpstan`, `phpstan-command` | `false`, `vendor/bin/phpstan analyse --no-progress` | Also run PHPStan. |
| `env` | none | `KEY=VALUE` lines added to the job's environment. |
| `postgres`, `postgres-image`, `postgres-db`, `postgres-user`, `postgres-password` | `false`, `postgres:15`, `test`, `test`, `ci-only-not-a-secret` | Run beside PostgreSQL on `127.0.0.1:5432`. |
| `timeout-minutes` | `30` | The job's time limit. |

### `changelog-fragment.yml`: changelog fragments

Checks `changelog.d/` with the one copy of the changelog tool, whity-core's
`scripts/changelog-assemble.php`. Repositories don't keep their own copy.

```yaml
jobs:
  changelog:
    uses: whity-org/.github/.github/workflows/changelog-fragment.yml@main
```

Inputs: `name` (`Changelog fragments`), `working-directory` (`.`), `tool-ref`
(the whity-core branch, `develop`).

## Required checks

A job that calls a reusable workflow reports its checks as
`<calling job> / <job name>`. If branch protection requires a check by its old
name, keep a small job with that exact name that passes only when the called
job succeeded:

```yaml
  tests-gate:
    name: Tests
    needs: tests
    if: always()
    runs-on: ubuntu-latest
    steps:
      - run: test "${{ needs.tests.result }}" = success
```

## Changelog at release

Fold the fragments into `CHANGELOG.md` from the repository root:

```sh
curl -fsSL https://raw.githubusercontent.com/whity-org/.github/main/changelog/assemble.sh | sh
```

Add `-s -- --check` to only check them.
