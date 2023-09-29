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
Cypress is used to test the JavaScript code. Component tests will live next to the component file in the named folder. End to end tests live in "cypress/e2e". For reference on when to write which, refer to the [Cypress testing types documentation](https://docs.cypress.io/guides/core-concepts/testing-types#What-is-E2E-Testing).

#### CLI (via Docker)
``` bash
docker compose exec cypress-tests sh
  # ref package.json for the underlying commands of the scripts below
  yarn cy:comp
  yarn cy:e2e
```

- You can also use other cypress commands via `yarn run [COMMAND]`
  - Ref: https://docs.cypress.io/guides/guides/command-line#cypress-run
  - Cypress defaults to running e2e tests. To run component tests without the script above, `--component` must be used.

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
_NOTE: if you run lint on more than a single file without one of the scripts, add `--ext .jsx,.js`_

```bash
docker compose exec web sh
yarn lint -h # list all eslint cli options
yarn lint # this will do nothing on its own. you must pass it additional options
  # e.g.: `yarn lint app/javascript/components/App.jsx` which will lint that file
yarn lint:all # lint all available files
yarn lint <relative-path-to-file> # lint one file
```
