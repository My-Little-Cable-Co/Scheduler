FROM ruby:2.7.8-bullseye

## Install Yarn.

ADD https://dl.yarnpkg.com/debian/pubkey.gpg /tmp/yarn-pubkey.gpg
RUN apt-key add /tmp/yarn-pubkey.gpg && rm /tmp/yarn-pubkey.gpg
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y python2 yarn

WORKDIR /src

COPY Gemfile /src/Gemfile
#COPY Gemfile.lock /src/Gemfile.lock

RUN bundle install

COPY . /src

## Run yarn install to install JavaScript dependencies.
RUN yarn install --check-files

EXPOSE 3000

CMD 'serve.sh'
