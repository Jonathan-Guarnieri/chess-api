FROM ruby:3.4.2-bullseye as base

RUN apt-get update -qq && apt-get install -y build-essential apt-utils libpq-dev nodejs

WORKDIR /chess-api

RUN gem install bundler

COPY Gemfile* ./

RUN bundle install

ADD . /chess-api

ARG DEFAULT_PORT 3000

EXPOSE ${DEFAULT_PORT}

CMD [ "bundle", "exec", "rails", "server", "-b", "0.0.0.0" ]
