# VIVA

## Table of Contents

- [Getting Started](#getting-started)
- [Testing](#testing)
  - [RSpec](#rspec)
  - [Cypress](#cypress)
- [Linting](#linting)

---

## Getting Started

- To run the application using Docker, will need to have Docker installed on your machine.
  [Get Docker](https://docs.docker.com/get-docker/)

- Once Docker is installed and running:

  ```bash
  docker compose up
  ```

  _NOTE: if the above command fails with `Build with Vite failed!`, uncheck the "Use Virtualization framework" setting in the Docker settings under the "General" tab. Apply the change and restart Docker. Then restart the app:_

  ```bash
  docker compose down -v
  docker compose up
  ```

- The first time you start your app, you need to set up your database

  ```bash
  docker compose exec web sh
  rails db:create db:migrate db:seed
  ```

- After running `dory up`, you can view the app in the browser at `http://viva.test`.

## Testing

### RSpec
RSpec is used to test the Rails code.

```bash
docker compose exec web bash
bundle exec rspec
```

### Cypress
Cypress is used to test the JavaScript code.
_NOTE: comment out `RubyPlugin()` in "vite.config.ts", before opening the Launchpad or the test suite will hang. (Reference: [this comment](https://github.com/cypress-io/cypress/issues/23903#issuecomment-1515286486))_

1. Open the Cypress Launchpad: `yarn run cypress open --component`
    - If/when end-to-end tests are configured, use the `--e2e` flag to run those tests
2. Choose a browser to run the tests in.
    - This opens the test suite in the browser you chose
3. Click on the name of the test you'd like to run

## Linting

This app has rubocop installed. To run linting inside the web container:

```bash
docker compose exec web bash
bundle exec rubocop
```
