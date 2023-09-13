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

#### CLI
_NOTE: Cypress defaults to running e2e tests. To run component tests, add `--component` to any of the commands you run._

- Use one of the `cypress:run` scripts in the [package.json](./package.json) file
- If you don't see the command you'd like to run, use `yarn run [COMMAND]`
  - Ref: https://docs.cypress.io/guides/guides/command-line#Commands

``` bash
# examples
yarn cypress:run
# yarn cypress:run --component # This does not work at the moment.
  # Outside the containers it throws a "The package "@esbuild/darwin-x64" could not be found, and is needed by esbuild." error.
  # Inside the web container it throws an "xvfb" error. (https://docs.cypress.io/guides/continuous-integration/introduction#Xvfb)
yarn cypress:run --spec 'cypress/e2e/splash.cy.jsx'
```

#### LaunchPad
_NOTE: comment out `RubyPlugin()` in "vite.config.ts", before opening the Launchpad or the test suite will hang. (Reference: [this comment](https://github.com/cypress-io/cypress/issues/23903#issuecomment-1515286486))_

1. Open the Cypress Launchpad: `yarn cypress:open`
2. Choose to run end-to-end or component tests.
3. Select a browser to run the tests in.
    - This opens the test suite in the browser you chose
3. Click on the name of the test you'd like to run

## Linting

This app has rubocop installed. To run linting inside the web container:

```bash
docker compose exec web bash
bundle exec rubocop
```
