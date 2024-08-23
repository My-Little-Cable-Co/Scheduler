FROM ruby:3.3.4-bookworm

WORKDIR /src

COPY Gemfile /src/Gemfile
COPY Gemfile.lock /src/Gemfile.lock

RUN bundle install

COPY . /src

EXPOSE 3000

CMD 'serve.sh'
