FROM python:3.7.10-alpine3.13

ENV APP_HOME /usr/src/app/
ENV RAILS_ENV "production"
ENV NGINX_MAX_UPLOAD_SIZE 50m
ENV CANVAS_VER "release/2021-03-03.17"
ENV PASSENGER_VERSION=6.0.8
ENV DISABLE_V8_COMPILE_CACHE 1
ENV XMLSEC_VERSION=1.2.30

USER root
WORKDIR ${APP_HOME}

RUN apk add --no-cache build-base \
  linux-headers \
  autoconf automake \
  gnupg \
  libressl \
  gcc \
  bash \
  vim \
  ca-certificates \
  wget \
  git \
  libxml2 libxml2-dev libxslt libxslt-dev \
  make \
  patch \
  openssh \
  zip \
  unzip \
  zlib \
  zlib-dev \
  ruby \
  bison \
  bind-tools \
  bzip2 \
  g++ \
  readline-dev \
  wget \
  postgresql \
  postgresql-dev \
  curl-dev \
  pcre-dev \
  postgresql-client \
  rsync \
  icu-dev \
  sqlite-dev \
  nodejs nodejs-npm \
  shared-mime-info \
  tzdata \
  tar \
  procps \
  procps-dev \
  ruby ruby-dev ruby-bundler ruby-doc ruby-etc ruby-json

# Compile xmlsec library because of course nothing works.
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

RUN gem install passenger -v ${PASSENGER_VERSION} \
  && passenger-install-nginx-module --auto-download --auto --prefix=/opt/nginx \
  && passenger-config install-agent --auto \
  && passenger-config install-standalone-runtime --auto

RUN npm install --global yarn@1

RUN \
  # Never use git:// because not everyone can use it.
  git config --global url."https://".insteadOf git:// \
  && git clone https://github.com/instructure/canvas-lms.git ${APP_HOME} \
  && git checkout ${CANVAS_VER}

RUN \
  bundle config set --local path 'vendor/bundle' \
  bundle install --jobs 8 \
  && rm -rf .yarncache \
  && yarn install --pure-lockfile --force --cache-folder .yarncache --network-concurrency 1 \
  && rm -rf .yarncache/

RUN \
  for config in amazon_s3 database \
     delayed_jobs domain file_store outgoing_mail security external_migration; \
     do cp config/$config.yml.example config/$config.yml; done

RUN \
  rm -rf /opt/nginx/html && \
  ln -s ${APP_HOME}/public /opt/nginx/html

COPY config/*.yml /${APP_HOME}/config/

COPY nginx/nginx.conf /opt/nginx/conf/
COPY entrypoint.sh /canvas-entrypoint.sh

EXPOSE 443
EXPOSE 80

ENTRYPOINT ["/canvas-entrypoint.sh"]
