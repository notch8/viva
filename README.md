<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [VIVA](#viva)
  - [About](#about)
    - [Examples](#examples)
  - [Question Types](#question-types)
    - [Importing a CSV](#importing-a-csv)
    - [Common Columns](#common-columns)
      - [Indexed Columns](#indexed-columns)
    - [Question Type Documentation](#question-type-documentation)
  - [Exporting XML](#exporting-xml)
  - [Question Types](#question-types-1)
    - [Importing a CSV](#importing-a-csv-1)
    - [Common Columns](#common-columns-1)
      - [Indexed Columns](#indexed-columns-1)
    - [Question Type Documentation](#question-type-documentation-1)
    - [Exporting XML](#exporting-xml-1)
  - [Development](#development)
    - [Getting Started](#getting-started)
    - [Creating New Question Types](#creating-new-question-types)
      - [Model](#model)
      - [React Component](#react-component)
      - [XML Export](#xml-export)
    - [Testing](#testing)
      - [RSpec](#rspec)
      - [Cypress](#cypress)
        - [Running On Your Machine](#running-on-your-machine)
        - [LaunchPad](#launchpad)
    - [Linting](#linting)
      - [Rubocop](#rubocop)
      - [ESLint](#eslint)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# VIVA

A prototype for uploading classroom questions, searching for existing questions, and exporting questions.

## About

This application, with a Rails back-end and React front-end, prototypes a "Classroom question exchange".  It provides a "simplified" CSV import format for a variety of questions.

The CSV format is not as expressive as the XML format of something like QTI; as such the questions are more paired down.  It is envisioned that once you pick the questions, you would export them into another application to add the more granular information for your specific use-case.

### Examples

There is an [Examples directory README](./examples/README.md) that provides insight into the examples of quizzes exported to Canvas as well as imported into Canvas.

## Question Types

The below table outlines the question types:

| Question Type         | Importer Supported | Exporter Available |
|-----------------------|--------------------|--------------------|
| Bow Tie               | Yes                | No                 |
| Categorization        | Yes                | Yes                |
| Drag and Drop         | Yes                | No                 |
| Essay                 | Yes                | Yes                |
| Matching              | Yes                | Yes                |
| Select All That Apply | Yes                | Yes                |
| Stimulus Case Study   | Yes                | No                 |
| Traditional           | Yes                | Yes                |
| Upload                | Yes                | Yes                |

### Importing a CSV

One of the design goals was to allow for the import of heterogeneous sets of collections.  As such, the design aimed to re-use column names and concepts where possible.

In the CSV, the first row **must** be the header row.

When your cell contains commas, you will need to quote that cell.  If you’re using Excel or Google Sheets to write these CSVs; it will automatically add the quotes.

When your cell needs commas and quotes, you’ll need to escape the quotes.  Excel or Google Sheets will automatically handle this.


### Common Columns

All question types support the following CSV headers:

-   `IMPORT_ID` (Required): A number that is unique to all of the entries in the CSV.
-   `TYPE` (Required): The type of question; valid entries are:
    -   Bow Tie
    -   Categorization
    -   Drag and Drop
    -   Essay
    -   Matching
    -   Select All That Apply
    -   Stimulus Case Study
    -   Traditional
    -   Upload
-   `KEYWORD` (Recommended): One or more phrases that describe the question; separate each phrase with a comma
-   `SUBJECT` (Recommended): One or more subjects that are topical for this question; separate each phrase with a comma
-   `LEVEL` (Recommended):

A reminder, when you want to have a comma (e.g. `,`) in a cell, you must wrap the cell in double hack marks (e.g. `"`).

Below is an example in which the question will have the "Introspection" and "Group Feedback" keywords and the "History" and "Literature" subjects.

| IMPORT_ID | TYPE        | KEYWORD                         | SUBJECT               |
|-----------|-------------|---------------------------------|-----------------------|
| 1         | Traditional | "Introspection, Group Feedback" | "History, Literature" |

#### Indexed Columns

An ordinal column will be written in the form `COLUMN_NAME_i` where `COLUMN_NAME` is text and `i` is the index, represented as an integer.  The indices are used for indicating sequential order and referencing other indexed columns.

### Question Type Documentation

<details><summary>Bow Tie</summary>

The Bow Tie question type has three regions: left, center, and right.  Each region has possible answers, one or more correct answers.

-   `LEFT_LABEL`: The prompt for selecting the correct left portion of the bow tie.
-   `LEFT_i`: The text of possible choices for the left of the bow tie.
-   `LEFT_CORRECT_ANSWERS`: One or more integers, separated by commas, where the integers reference an `LEFT_i` column.

-   `CENTER_LABEL`: The prompt for selecting the correct center portion of the bow tie.
-   `CENTER_i`: The text of possible choices for the center of the bow tie.
-   `CENTER_CORRECT_ANSWERS`: One or more integers, separated by commas, where the integers reference an `CENTER_i` column.

-   `RIGHT_LABEL`: The prompt for selecting the correct right portion of the bow tie.
-   `RIGHT_i`: The text of possible choices for the right of the bow tie.
-   `RIGHT_CORRECT_ANSWERS`: One or more integers, separated by commas, where the integers reference an `RIGHT_i` column.

| Text                                         | LEFT_1       | LEFT_2         | LEFT_LABEL | LEFT_CORRECT_ANSWERS | CENTER_1         | CENTER_2                | CENTER_LABEL | CENTER_CORRECT_ANSWERS | RIGHT_1        | RIGHT_2 | RIGHT_LABEL | RIGHT_CORRECT_ANSWERS |
|----------------------------------------------|--------------|----------------|------------|----------------------|------------------|-------------------------|--------------|------------------------|----------------|---------|-------------|-----------------------|
| They starred in this movie as this character | Judy Garland | Robin Williams | Actor      | 1                    | The Wizard of Oz | The Empire Strikes Back | Movie        | 1                      | Mrs. Doubtfire | Dorothy | Character   | 2                     |

In this simple bow-tie with one correct answer in each position, we have Judy Garland starring in *The Wizard of Oz* as the character Dorothy.

</details>

<details><summary>Categorization</summary>

-   `LEFT_i`: The categories in which each of the options will be placed.
-   `RIGHT_i`: The options to place in the categories

| TEXT            | LEFT_1 | LEFT_2 | RIGHT_1      | RIGHT_2          |
|-----------------|--------|--------|--------------|------------------|
| Match the pairs | Color  | Food   | "Red, Green" | "Carrot, Celery" |

In the above fragment of CSV, the question prompt is "Match the pairs".  And the student will need to match the *left* terms of "Color" and "Food" to the *right* terms of "Red", "Green", "Carrot", and "Celery.  The correct answer for "Color" is "Red" and "Green".  We indicate correct pairs via the index (e.g. `LEFT_1` matches `RIGHT_1`).

*Note:* The Matching question is similar to the Categorization.  The difference is that the Categorization supports multiple values in the `RIGHT_i` columns.
</details>

<details><summary>Drag and Drop</summary>

The Drag and Drop is similar to Select All That Apply, allowing one or more correct answers.  The drag and drop has two “forms”:

</details>

<details><summary> Form One</summary>

Form one is identical to the later described Select All that Apply.

-   `ANSWER_i`: The plain text of a possible answer to the question.
-   `CORRECT_ANSWERS`: one or more integers, separated by commas, where the integers reference an `ANSWER_i` column.

| TEXT                       | CORRECT_ANSWERS | ANSWER_1 | ANSWER_2 | ANSWER_3 | ANSWER_4 | ANSWER_5 | ANSWER_6 |
|----------------------------|-----------------|----------|----------|----------|----------|----------|----------|
| Select the primary colors: | 2,4,6           | Green    | Red      | Orange   | Yellow   | Purple   | Blue     |

The primary colors are Red, Yellow, and Blue.

</details>

<details><summary> Form Two</summary>

In this form, we do not need to include a `CORRECT_ANSWERS` column; it is derived from the `TEXT`.

| TEXT                                                | ANSWER_1 | ANSWER_2 | ANSWER_3 | ANSWER_4 |
|-----------------------------------------------------|----------|----------|----------|----------|
| The \_\_\_2\_\_\_ loves the smell of \_\_\_3\_\_\_. | Dogwood  | Cat      | Catnip   | Blue     |

In the above example, the `___2___` references `ANSWER_2` column and `___3___` references `ANSWER_3`; creating the sentence “The cat loves the smell of catnip.”
</details>

<details><summary>Essay</summary>

-   `TEXT`: The first line of text.
-   `TEXT_i`: The sequential lines of text.

In the above, a “line of text” refers to paragraph, list item, etc.; that is each place where there’s a carriage return/someone typed `Enter` or `Return`.

| TEXT                      | TEXT_1                                                     | TEXT_2                                            |
|---------------------------|------------------------------------------------------------|---------------------------------------------------|
| Phrase for consideration: | "\_At the fork in the road, I took the path less traveled\_" | "What, if anything, might the author have meant?" |

As part of the import, we transform the text cells with the following consideration:

1.  For security purposes,  all text of HTML tags.
2.  Join all text fields in their index order, where `TEXT` is always the first line.
3.  Convert the text to safe HTML via a Markdown converter.

For more information on Markdown see [Markdown Cheat Sheet | Markdown Guide](https://www.markdownguide.org/cheat-sheet/).

In the above example we will produce the following HTML:

```html
<p>Phrase for consideration:</p>
<p><i>At the fork in the road, I took the path less traveled”</i><p>
<p>What, if anything, might the author have meant?</p>
```

</details>

<details><summary>Matching</summary>

The Matching question is similar to the Categorization question; with one difference.  Where the Categorization question supports multiple "right" side values, the Matching question supports only one value on the "right".

-   `LEFT_i` indexed columns: The "left" side of the matching pair.
-   `RIGHT_i` indexed columns: The "right" side of the matching pair.

| TEXT            | LEFT_1 | LEFT_2 | RIGHT_1 | RIGHT_2 |
|-----------------|--------|--------|---------|---------|
| Match the pairs | Color  | Food   | Red     | Bread   |

In the above fragment of CSV, the question prompt is "Match the pairs".  And the student will need to match the *left* terms of "Color" and "Food" to the *right* terms of "Red" and "Bread".  The correct answer for "Color" is "Red".  We indicate correct pairs via the index (e.g. `LEFT_1` matches `RIGHT_1`).
</details>

<details><summary>Select All That Apply</summary>

The Select All That Apply question is similar to the Traditional question, with the primary difference being that the Select All That Apply allows for more than one correct answer.

-   `ANSWER_i`: The plain text of a possible answer to the question.
-   `CORRECT_ANSWERS`: one or more integers, separated by commas, where the integers reference an `ANSWER_i` column.

| TEXT                       | CORRECT_ANSWERS | ANSWER_1 | ANSWER_2 | ANSWER_3 | ANSWER_4 | ANSWER_5 | ANSWER_6 |
|----------------------------|-----------------|----------|----------|----------|----------|----------|----------|
| Select the primary colors: | 2,4,6           | Green    | Red      | Orange   | Yellow   | Purple   | Blue     |

The primary colors are Red, Yellow, and Blue.
</details>

<details><summary>Stimulus Case Study</summary>

The Stimulus Case Study is comprised of other questions, instead of having answers a Stimulus Case Study is referenced by later rows via the `PART_OF` column.

| IMPORT_ID | TYPE                  | TEXT                                                                               | PART_OF | CORRECT_ANSWERS | ANSWER_1 | ANSWER_2 | ANSWER_3    | ANSWER_4   |
|-----------|-----------------------|------------------------------------------------------------------------------------|---------|-----------------|----------|----------|-------------|------------|
| 1         | Stimulus Case Study   | In this case study we’ll discuss Muppets                                           |         |                 |          |          |             |            |
| 2         | Select All That Apply | In the original Muppet Movie which two Muppets first road together in a Studebaker | 1       | 2,3             | Gonzo    | Kermit   | Fozzie Bear | Miss Piggy |

In the above example, the Select All That Apply question is *part of* the Stimulus Case Study.  All questions that are part of a Stimulus Case Study will not be individually filterable.
</details>

<details><summary>Traditional</summary>

Like the Traditional question is similar to the Select All That Apply question, with the primary difference being that the Traditional allows for one and only one correct answer.

-   `ANSWER_i`: The plain text of a possible answer to the question.
-   `CORRECT_ANSWERS`: one integer that references an `ANSWER_i` column.

| TEXT                             | CORRECT_ANSWERS | ANSWER_1 | ANSWER_2 | ANSWER_3 |
|----------------------------------|-----------------|----------|----------|----------|
| Which color is comprised of Red: | 2               | Green    | Purple   | Blue     |

Purple is comprised of Red (and Blue).

</details>

<details><summary>Upload</summary>

As of <span class="timestamp-wrapper"><span class="timestamp">&lt;2023-12-14 Thu&gt;</span></span>, the Upload question behaves in the same manner as the Essay question; see it’s documentation for details.
</details>

## Exporting XML

From the home page.

-   Select your search criteria.
-   Click the “Search” button.

The Search Filters section shows your chosen search criteria.

-   Click “Export Questions” and select “XML”

This will download an `.xml` file (e.g. `questions-2023-12-13_15_38_01_508.classic-question-canvas.qti.xml`).  To upload that file into Canvass you will need to convert the downloaded XML file into a `.zip` file.  The way to do this varies by operating system.

As of <span class="timestamp-wrapper"><span class="timestamp">&lt;2023-12-13 Wed&gt; </span></span> we export into a “classic question” format; the rationalization being two fold:

1.  Canvas presently supports both “classic” and “new” formats.
2.  In Canvas you may migrate “Classic” questions to “new” formats, but not vice versa.

*Note:* Only after providing a Search Filter will you be able to “Export” questions.

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
