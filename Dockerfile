FROM ruby:3.0.1

LABEL maintainer="chris@chrisalley.info"

RUN apt update -y && apt install -y --no-install-recommends \
  build-essential \
  imagemagick

# Install a recent version of nodejs.
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt install -y nodejs

# Install Yarn.
RUN wget --quiet -O - /tmp/pubkey.gpg https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update && apt install -y yarn

# Remove packages that were automatically installed to satisfy dependencies.
RUN apt autoremove -y

# Install bundler and gems.
COPY Gemfile* /cms/
WORKDIR /cms

RUN gem install bundler --version=2.2.20
RUN bundle install

# Copy the project's files into the container.
COPY . /cms

# Run yarn install at this point to enable webpack-dev-server command.
RUN yarn cache clean
RUN yarn install

# Execute entrypoint script every time the container starts.
COPY docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# Precompile assets for production.
RUN rails assets:clobber
RUN RAILS_ENV=production SECRET_KEY_BASE=abcd1234 rails assets:precompile --trace

# Start the main process.
CMD ["rails", "s", "-b", "0.0.0.0"]
