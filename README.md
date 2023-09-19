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
Cypress is used to test the JavaScript code. Learn more about how to write these tests at https://docs.cypress.io/api/table-of-contents.

#### CLI
_NOTE: Cypress defaults to running e2e tests. To run component tests, `--component` must be used._

- Use one of the `cy` scripts in the [package.json](./package.json) file
- If you don't see the command you'd like to run, use `yarn run [COMMAND]`
  - Ref: https://docs.cypress.io/guides/guides/command-line#Commands

``` bash
# examples
yarn cy:e2e
# yarn cy:comp # TODO: Figure out why component tests are broken now.
  # Inside the web container it throws an "xvfb" error. (https://docs.cypress.io/guides/continuous-integration/introduction#Xvfb)
yarn cy:comp --spec 'cypress/e2e/splash.cy.jsx'
```

#### LaunchPad
_NOTE: comment out `RubyPlugin()` in "vite.config.ts", before opening the Launchpad or the test suite will hang. (Reference: [this comment](https://github.com/cypress-io/cypress/issues/23903#issuecomment-1515286486))_

1. Open the Cypress Launchpad: `yarn cy:open`
2. Choose to run end-to-end or component tests.
3. Select a browser to run the tests in.
    - This opens the test suite in the browser you chose
3. Click on the name of the test you'd like to run

## Linting
### Rubocop
For Rails code.

```bash
docker compose exec web sh
rubocop -h # list all rubocop cli options
rubocop # lint all available files
```

### ESLint
For JavScript code. Refer to the `lint` scripts in package.json to understand the underlying command. Using `yarn` with a script is equivalent to using `yarn run <command>`.

```bash
docker compose exec web sh
yarn lint -h # list all eslint cli options
yarn lint # this will do nothing on its own. you must pass it additional options
  # e.g.: `yarn lint app/javascript/components/App.jsx` which will lint that file
yarn lint:all # lint all available files
```
