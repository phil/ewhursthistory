FROM ruby:4.0.1

# RUN apt-get update && apt-get install -y \
#   libvips

RUN gem update --system
ENV BUNDLE_VERSION "4.0.6"
RUN gem install bundler -v "$BUNDLE_VERSION"
