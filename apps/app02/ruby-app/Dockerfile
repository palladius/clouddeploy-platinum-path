FROM ruby:2.7

WORKDIR /app
ADD Gemfile* ./
RUN bundle install

ADD . ./

# Puma serves on 9292 by default. With this we bend it back to Carlessian deafult.
CMD ["bundle","exec","puma", "-p", "8080"]

# Note from Alex: this doesn't guarantee anything. It's just a documentation thingy. Might be worth even REMOVING it.
# https://kubernetes.io/docs/concepts/services-networking/service/#proxy-mode-ipvs
# https://docs.docker.com/engine/reference/builder/#expose
EXPOSE 8080
