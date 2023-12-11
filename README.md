# VIVA

A prototype for uploading classroom questions, searching for existing questions, and exporting questions.

## Table of Contents

- [About](#about)
- [Development](#development)
  - [Getting Started](#getting-started)
  - [Testing](#testing)
    - [RSpec](#rspec)
    - [Cypress](#cypress)
  - [Linting](#linting)

---

## About

This application, with a Rails back-end and React front-end, prototypes a "Classroom question exchange".  It provides a "simplified" CSV import format for a variety of questions.

The CSV format is not as expressive as the XML format of something like QTI; as such the questions are more paired down.  It is envisioned that once you pick the questions, you would export them into another application to add the more granular information for your specific use-case.

### Examples

There is an [Examples directory README](./examples/README.md) that provides insight into the examples of quizzes exported to Canvas as well as imported into Canvas.

## Development

### Getting Started

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

### Creating New Question Types

You will need:

- A *model* and corresponding specs
- A *React component* for rending the question in the [Search results](./app/controllers/search_controller.rb)
- An *XML export* view and corresponding specs

#### Model

Each new question type **must** be a direct descendant of [`Question`](./app/models/question.rb).  As duplicate logic for questions emerges, extract a module that extends `Active::Support`.  See [MarkdownQuestionBehavior](./app/models/concerns/markdown_question_behavior.rb) for an example of the module and [`Question::Upload`](./app/models/question/upload.rb) or [`Question::Essay`](./app/models/question/essay.rb) for implementation.

#### React Component

TBD

#### XML Export

Each new question should implement specs to ensure conformance to expectations.  The [`./spec/models/question/`](./spec/models/question/) directory has many examples; including leveraging [share examples](./spec/shared_examples.rb)

As you work on questions, you'll also be looking at writing views that represent their export to QTI XML format.  See [./app/views/question/README.md](./app/views/question/README.md) for an overview of how we create XML templates for questions.

### Testing

#### RSpec
RSpec is used to test the Rails code.

```bash
docker compose exec web bash
bundle exec rspec
```

#### Cypress
Cypress is used to test the JavaScript code. Component tests will live next to the component file in the named folder. End to end tests live in "cypress/e2e". For reference on when to write which, refer to the [Cypress testing types documentation](https://docs.cypress.io/guides/core-concepts/testing-types#What-is-E2E-Testing).

There are two cypress tests:

- components :: runs to test the React components
- end to end (e2e) :: runs with a browser and verifies that the homepage renders.

There is a `cypress-tests` container that runs as part of the build.  To run the cypress test locally there are two options:

- `docker compose up cypress-tests` :: will run the e2e tests
- `yarn cypress:run` :: will run them cypress tests on your machine (see *Running on Your Machine* for the full details)

##### Running On Your Machine

For this to work, there are a few steps to take:

- Install Cypress (e.g. `yarn install`)
- Update [./cypress.config.js](./cypress.config.js); replacing `baseUrl: 'http://web:3000'` with `baseUrl: 'http://viva.test'`.  (This is done because you'll be running Cypress against your machines environment instead of within the docker ecosystem)
- `yarn cypress:run` to run the e2e tests.
- `yarn cypress:run --components` to run the component tests.

_Note: You cannot run the Cypress tests within the `web` container because it does not, by design and intention, have the development dependencies necessary for Cypress._

##### LaunchPad
_NOTE: comment out `RubyPlugin()` in "vite.config.ts", before opening the Launchpad or the test suite will hang. (Reference: [this comment](https://github.com/cypress-io/cypress/issues/23903#issuecomment-1515286486))_

0. Update the `./cypress.config.js` as listed above.
1. Open the Cypress Launchpad: `yarn cypress:open`
2. Choose to run end-to-end or component tests.
3. Select a browser to run the tests in.
    - This opens the test suite in the browser you chose
3. Click on the name of the test you'd like to run

### Linting
#### Rubocop
For Rails code.

```bash
docker compose exec web sh
rubocop -h # list all rubocop cli options
rubocop # lint all available files
```

#### ESLint
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
