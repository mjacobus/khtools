# Kingdom Hall Tools

A few utilities for Kingdom Hall users.

[![Build Status](https://github.com/mjacobus/khtools/actions/workflows/rails-unit-tests.yml/badge.svg)](https://github.com/mjacobus/khtools/actions/workflows/rails-unit-tests.yml?query=branch%3Amaster)
[![Rubocop](https://github.com/mjacobus/khtools/actions/workflows/rubocop.yml/badge.svg)](https://github.com/mjacobus/khtools/actions/workflows/rubocop.yml?query=branch%3Amaster)
[![Maintainability](https://api.codeclimate.com/v1/badges/65fad0b0ff0bed478231/maintainability)](https://codeclimate.com/github/mjacobus/khtools/maintainability)
[![Coverage Status](https://coveralls.io/repos/github/mjacobus/khtools/badge.svg?branch=master)](https://coveralls.io/github/mjacobus/khtools?branch=master)

### How to run/install the app

After installing the ruby version displayed in [this file](https://github.com/mjacobus/khtools/blob/master/.ruby-version).
Also install `nodejs` and `yarn`.

```bash
# first time
gem install bundler
mkdir ~/Projects
cd projects
git clone https://github.com/mjacobus/khtools.git
cd khtools
bundle install # after you installed ruby version
cp .env.sample .env

yarn install

# every time you update your project

cd ~/Projects/khtools
bundle install
./bin/rake db:create  # create database
./bin/rake db:migrate # create tables
./bin/rake db:seed    # create fake data for the database

./bin/rails server    # to stop the server hit <ctrl>+C
```

### Running tests

```bash
RAILS_ENV=test ./bin/rake db:create  # create test database
RAILS_ENV=test ./bin/rake db:migrate # create test tables
./bin/rspec
```

### Fixing files style after changing

```bash
bundle exec rubocop -a
```

### Installing OS dependencies

- If you are on [Ubuntu 18.04 LTS](https://github.com/mjacobus/installers/tree/master/ubuntu/18.04)
- The above step is not installing ruby itself. However you can try to use [asdf for ruby](https://github.com/asdf-vm/asdf-ruby).
- Same for nodejs and yarn. Try [asdf for nodejs](https://github.com/asdf-vm/asdf-nodejs) and after installing run `npm install -g yarn`.

### Editing credentials

The master key is stored in 1password, and the development key is the same as prod.

```
RAILS_MASTER_KEY=the-key bin/rails credentials:edit

RAILS_MASTER_KEY=12345678901234567890123456789012 bin/rails credentials:edit --environment test
```
