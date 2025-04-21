FROM ruby:3.4.3

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y build-essential libsqlite3-dev nodejs yarn

COPY . .

RUN bundle install
RUN yarn install --check-files || true

# Optional: precompile assets (enable if you’re not using Kamal asset hook)
# RUN bundle exec rake assets:precompile

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
