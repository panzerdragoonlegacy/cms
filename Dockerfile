FROM ruby:3.0.1

LABEL maintainer="chris@chrisalley.info"

RUN apt-get update -y && apt-get install -y --no-install-recommends \
  build-essential \
  imagemagick

# Install Yarn and Node
RUN wget --quiet -O - /tmp/pubkey.gpg https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update && apt install -y yarn

COPY Gemfile* /cms/
WORKDIR /cms

RUN gem install bundler --version=2.2.20
RUN bundle install

COPY . /cms

# Execute entrypoint script every time the container starts.
COPY docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# Precompile assets
RUN rails assets:clobber
RUN RAILS_ENV=production SECRET_KEY_BASE=abcd1234 rails assets:precompile --trace

# Start the main process.
CMD ["rails", "s", "-b", "0.0.0.0"]
