FROM ruby:3.3.4-bookworm

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y ffmpeg && rm -rf /var/lib/apt/lists/*

WORKDIR /src

COPY Gemfile /src/Gemfile
COPY Gemfile.lock /src/Gemfile.lock

RUN bundle install

COPY . /src

EXPOSE 3000

CMD 'serve.sh'
