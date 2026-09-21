FROM ruby:3.4.3

WORKDIR /app

# This image only ever runs in production, so the development and test gems are
# left out. Besides keeping the image smaller, it keeps spring out of it: spring
# hijacks bin/rails and refuses to boot when cache_classes is true, which breaks
# `kamal app exec --interactive --reuse "bin/rails console"`.
ENV RAILS_ENV=production \
    BUNDLE_WITHOUT="development test"

RUN apt-get update -qq && \
    apt-get install -y build-essential libsqlite3-dev nodejs yarn

COPY . .

RUN bundle install
RUN yarn install --check-files || true

# Assets are built before the real master key is available, and they don't need
# it: a dummy secret is enough to boot the app for precompilation.
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rake assets:precompile

RUN mkdir -p tmp/pids

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
