FROM ruby:3.1.2 as viva-base
RUN apt-get update -qq && apt-get install -y postgresql-client
WORKDIR /viva
COPY Gemfile /viva/Gemfile
COPY Gemfile.lock /viva/Gemfile.lock
RUN bundle install

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
EXPOSE 3000

# Configure the main process to run when running the image
# CMD ["rails", "server", "-b", "0.0.0.0"]