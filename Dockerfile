FROM ruby:3.1.2 as viva-base
RUN apt-get update -qq && apt-get install -y postgresql-client

ENV APP_HOME /viva

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN gem install bundler:2.3.3

ADD Gemfile* $APP_HOME/
RUN (bundle check || bundle install)

COPY . $APP_HOME


# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
EXPOSE 3000
