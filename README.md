# README

## Starting the application

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

- The first time you start your app, you may need to create a database and/or run migrations

  ```bash
  docker compose exec web sh
  rails db:create db:migrate
  ```

- After running `dory up`, you can view the app in the browser at `http://viva.test`.

## Running the test suite

You can run the test suite from inside the web container

```bash
docker compose exec web bash
bundle exec rspec
```

## Linting

This app has rubocop installed. To run linting inside the web container:

```bash
docker compose exec web bash
bundle exec rubocop
```
