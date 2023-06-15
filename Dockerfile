FROM ruby:3.1.2 as viva-base
RUN apt-get update -qq && apt-get install -y postgresql-client

ENV APP_HOME /viva

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN gem install bundler:2.3.3

ADD Gemfile* $APP_HOME/
RUN (bundle check || bundle install)

COPY . $APP_HOME

RUN chmod +x ./ops/entrypoint.sh

ENTRYPOINT ["/bin/bash", "./ops/entrypoint.sh"]