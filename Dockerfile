FROM ruby:3.1.4 as viva-base
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - &&\
  apt-get update -qq &&\
  apt-get install -y \
    nodejs \
    postgresql-client && \
  npm install -g yarn

ENV APP_HOME /app

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN gem install bundler:2.3.3

ADD Gemfile* $APP_HOME/
RUN (bundle check || bundle install)

ADD package.json ./package.json
ADD yarn.lock ./yarn.lock
RUN yarn install
# RUN CYPRESS_CACHE_FOLDER=~/.cache/Cypress yarn install

COPY . $APP_HOME
RUN bash -l -c " \
    NODE_ENV=production DB_ADAPTER=nulldb bundle exec rake assets:precompile && \
    mv public/assets public/assets-new"

RUN chmod +x ./ops/entrypoint.sh

ENTRYPOINT ["/bin/bash", "./ops/entrypoint.sh"]
