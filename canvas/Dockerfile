FROM python:3.7.10-alpine3.13

ENV APP_HOME /usr/src/app/
ENV RAILS_ENV "production"
ENV NGINX_MAX_UPLOAD_SIZE 50m
ENV CANVAS_VER "release/2021-03-03.17"
ENV ENV="/etc/profile.d/rbenv.sh"
ENV RBENV_ROOT=/usr/local/rbenv
ENV RBENV_VERSION=2.6.5
ENV RBENV_DOCVERSION=2.6.5
ENV PASSENGER_VERSION=6.0.8
ENV DISABLE_V8_COMPILE_CACHE 1

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
  procps-dev

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

RUN echo 'export RBENV_ROOT=/usr/local/rbenv' > /etc/profile.d/rbenv.sh\
  &&  echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh\
  &&  echo 'export PATH="$RBENV_ROOT/shims:$PATH"' >> /etc/profile.d/rbenv.sh\
  &&  echo 'eval "$(rbenv init -)"'  >> /etc/profile.d/rbenv.sh\
  &&  chmod +x /etc/profile.d/rbenv.sh

RUN git clone https://github.com/rbenv/rbenv.git ${RBENV_ROOT} \
  &&  mkdir -p ${RBENV_ROOT}/plugins \
  &&  git clone https://github.com/rbenv/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build \
  &&  git clone https://github.com/rbenv/rbenv-vars.git ${RBENV_ROOT}/plugins/rbenv-vars \
  &&  source /etc/profile.d/rbenv.sh

RUN ${RBENV_ROOT}/bin/rbenv install ${RBENV_VERSION} \
  &&  ${RBENV_ROOT}/shims/gem install passenger -v ${PASSENGER_VERSION} \
  &&  ${RBENV_ROOT}/shims/passenger-install-nginx-module --auto-download --auto --prefix=/opt/nginx \
  &&  ${RBENV_ROOT}/shims/passenger-config install-agent --auto \
  &&  ${RBENV_ROOT}/shims/passenger-config install-standalone-runtime --auto \
  &&  ${RBENV_ROOT}/bin/rbenv rehash

RUN npm install --global yarn@1

RUN \
  # Never use git:// because not everyone can use it.
  git config --global url."https://".insteadOf git:// \
  && git clone https://github.com/instructure/canvas-lms.git ${APP_HOME} \
  && git checkout ${CANVAS_VER}

RUN \
  ${RBENV_ROOT}/shims/bundle install --jobs 8 --path vendor/bundle \
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
