# syntax=docker/dockerfile:1
FROM ruby:3.3.6 AS viva-base

# Install dependencies for the NodeSource repo and Node.js
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update -qq && \
    apt-get install -y ca-certificates curl gnupg && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

# Add the NodeSource repo for Node 22
ENV NODE_MAJOR=22
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

# Install Node.js and other dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update -qq && \
    apt-get install -y \
    nodejs \
    postgresql-client \
    vim-tiny \
    # Cypress dependencies
    xvfb \
    libgtk2.0-0 \
    libgtk-3-0 \
    libgbm-dev \
    libnotify-dev \
    libgconf-2-4 \
    libnss3 \
    libxss1 \
    libasound2 \
    libxtst6 \
    xauth && \
    npm install -g yarn

ENV APP_HOME=/app

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
# --frozen: fail the build if Gemfile.lock can't resolve as-is (e.g. a locked gem's
# platform build doesn't support this Ruby) instead of silently installing a
# different version that gets masked by the later `COPY . $APP_HOME`. If this
# fails, run `bundle lock --update <gem>` and commit the result.
RUN --mount=type=cache,target=/usr/local/bundle/cache,sharing=locked \
    bundle install --frozen

ADD package.json ./package.json
ADD yarn.lock ./yarn.lock
ADD .yarnrc.yml ./.yarnrc.yml
RUN --mount=type=cache,target=/usr/local/share/.cache/yarn,sharing=locked \
    yarn install --network-timeout 100000

COPY . $APP_HOME
RUN bash -l -c " \
    NODE_ENV=production DB_ADAPTER=nulldb bundle exec rake assets:precompile && \
    mv public/assets public/assets-new"

RUN chmod +x ./ops/entrypoint.sh

ENTRYPOINT ["/bin/bash", "./ops/entrypoint.sh"]
