FROM python:3.9.11-alpine3.14

ARG CANVAS_RAILS=7.0

ENV APP_HOME /usr/src/app/
ENV RAILS_ENV "development"
ENV NGINX_MAX_UPLOAD_SIZE 50m
ENV CANVAS_VER "stable/2023-03-01"
ENV BUNDLER_VERSION=2.3.26
ENV PASSENGER_VERSION=6.0.17
ENV DISABLE_V8_COMPILE_CACHE 1
ENV XMLSEC_VERSION=1.2.32
ENV NODEJS_VERSION=v16.19.0
ENV CANVAS_RAILS=${CANVAS_RAILS}

USER root
WORKDIR ${APP_HOME}

RUN apk add --no-cache build-base \
  linux-headers \
  autoconf automake \
  gnupg \
  gcc \
  bash \
  vim \
  ca-certificates \
  wget \
  git \
  libffi \
  libidn libidn-dev \
  libxml2 libxml2-dev libxslt libxslt-dev \
  make \
  patch \
  openssh \
  zip \
  unzip \
  zlib \
  zlib-dev \
  bison \
  bind-tools \
  bzip2 \
  xz \
  g++ \
  readline-dev \
  wget \
  # @todo switch to libpq libpq-dev when canvas can support alpine > 3.14.
  postgresql postgresql-dev \
  curl-dev \
  pcre-dev \
  postgresql-client \
  rsync \
  icu-dev \
  sqlite-dev \
  # @todo uncomment once canvas can support alpine > 3.14
  # nodejs npm \
  shared-mime-info \
  tzdata \
  tar \
  procps \
  procps-dev \
  ruby ruby-dev ruby-doc ruby-rdoc ruby-etc ruby-json ruby-rake ruby-bigdecimal ruby-fiddle

# Installs an "unofficial", official node.js build from nodejs.org.
# @todo remove once canvas can support alpine > 3.14.
RUN mkdir /opt/nodejs \
  && cd /opt/nodejs \
  && wget "https://unofficial-builds.nodejs.org/download/release/${NODEJS_VERSION}/node-${NODEJS_VERSION}-linux-x64-musl.tar.xz" \
  && tar -Jxvf node-${NODEJS_VERSION}-linux-x64-musl.tar.xz \
  && cd node-${NODEJS_VERSION}-linux-x64-musl \
  && ln -sv /opt/nodejs/node-${NODEJS_VERSION}-linux-x64-musl/bin/node /usr/bin/node \
  && ln -sv /opt/nodejs/node-${NODEJS_VERSION}-linux-x64-musl/bin/npm /usr/bin/npm \
  && ln -sv /opt/nodejs/node-${NODEJS_VERSION}-linux-x64-musl/bin/npx /usr/bin/npx \
  && ln -sv /opt/nodejs/node-${NODEJS_VERSION}-linux-x64-musl/bin/corepack /usr/bin/corepack \
  && cd ${APP_HOME}

# Instructure requires statically-linked xmlsec library to be compiled because..?
RUN mkdir /tmp/xmlsec \
  && cd /tmp/xmlsec \
  && wget "http://www.aleksey.com/xmlsec/download/xmlsec1-${XMLSEC_VERSION}.tar.gz" \
  && tar zxf "xmlsec1-${XMLSEC_VERSION}.tar.gz" \
  && cd "xmlsec1-${XMLSEC_VERSION}" \
  && ./configure \
        --prefix='/usr' \
        --enable-crypto-dl=no \
        --enable-pkgconfig \
  && make \
  && make install \
  && cd ${APP_HOME} \
  && rm -rf /tmp/xmlsec

RUN gem install bundler -v ${BUNDLER_VERSION} \
  # Why do I need to install a gem twice? Gems were a mistake. Seriously.
  && gem install strscan -v 3.0.5

RUN gem install passenger -v ${PASSENGER_VERSION} \
  && passenger-install-nginx-module --auto-download --auto --prefix=/opt/nginx \
  && passenger-config install-agent --auto \
  && passenger-config install-standalone-runtime --auto

RUN \
  rm -rf /opt/nginx/html && \
  ln -s ${APP_HOME}/public /opt/nginx/html

RUN \
  # Never use git:// because not everyone can use it.
  git config --global url."https://".insteadOf git:// \
  && git clone --depth 1 --branch ${CANVAS_VER} https://github.com/instructure/canvas-lms.git ${APP_HOME}

COPY config/*.yml /${APP_HOME}/config/

# Copies configuration and removes dumb canvas rake files that don't make sense
# to have in a production-like development environment because I don't know
# how to do it any better than removing the file.
RUN \
  for config in amazon_s3 database \
     domain file_store outgoing_mail security external_migration; \
     do cp config/$config.yml.example config/$config.yml; done ; \
  for rake_file in pact pact_broker rspec ; \
     do rm lib/tasks/$rake_file.rake ; done

RUN bundle config set --local path 'vendor/bundle' \
  && bundle config set --local without 'pulsar' \
  && bundle config set --local without test \
  && bundle install --jobs=8

RUN npm install --global yarn@1 \
  # @todo remove once canvas can support alpine > 3.14.
  && ln -sv /opt/nodejs/node-${NODEJS_VERSION}-linux-x64-musl/bin/yarn /usr/bin/yarn 

# Canvas installs over 2GB of node dependencies because..?
RUN --mount=type=cache,target=/tmp/.yarncache yarn install --pure-lockfile --force --cache-folder /tmp/.yarncache --network-concurrency 1

COPY nginx/nginx.conf /opt/nginx/conf/

COPY entrypoint.sh /canvas-entrypoint.sh

COPY config/*.yml ${APP_HOME}/config/

EXPOSE 443
EXPOSE 80

ENTRYPOINT ["/canvas-entrypoint.sh"]
