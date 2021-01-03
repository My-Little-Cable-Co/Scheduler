FROM ruby:2.7.2

WORKDIR /src

COPY Gemfile /src/Gemfile
COPY Gemfile.lock /src/Gemfile.lock

RUN bundle install

COPY . /src

## Install Yarn.
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn

## Run yarn install to install JavaScript dependencies.
RUN yarn install --check-files

CMD ["rails", "server", "-b", "0.0.0.0"]
