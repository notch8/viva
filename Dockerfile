FROM ruby:3.1.4 as viva-base

# Install dependencies for the NodeSource repo and Node.js
RUN apt-get update -qq && \
    apt-get install -y ca-certificates curl gnupg && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

# Add the NodeSource repo for Node 18
ENV NODE_MAJOR=18
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

# Install Node.js and other dependencies
RUN apt-get update -qq && \
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

ENV APP_HOME /app

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN gem install bundler:2.3.3

ADD Gemfile* $APP_HOME/
RUN (bundle check || bundle install)

ADD package.json ./package.json
ADD yarn.lock ./yarn.lock
ADD .yarnrc.yml ./.yarnrc.yml
RUN yarn install --network-timeout 100000

COPY . $APP_HOME
RUN bash -l -c " \
    NODE_ENV=production DB_ADAPTER=nulldb bundle exec rake assets:precompile && \
    mv public/assets public/assets-new"

RUN chmod +x ./ops/entrypoint.sh

ENTRYPOINT ["/bin/bash", "./ops/entrypoint.sh"]
