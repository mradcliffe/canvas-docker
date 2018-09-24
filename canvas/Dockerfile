FROM alpine:3.8

ENV APP_HOME /usr/src/app/
ENV RAILS_ENV "production"
ENV NGINX_MAX_UPLOAD_SIZE 50m
ENV CANVAS_VER "release/2018-10-06.05"
ENV ENV="/etc/profile.d/rbenv.sh"
ENV RBENV_ROOT=/usr/local/rbenv
# Until 2.4.5 is released we need to use a dev version because ruby.
ENV RBENV_VERSION=2.4.0-dev
ENV RBENV_DOCVERSION=2.4.0
ENV PASSENGER_VERSION=5.2.1
# ENV ac_cv_func_isnan yes
# ENV ac_cv_func_isinf yes
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
  tzdata \
  tar \
  procps \
  procps-dev

# Compile xmlsec library because of course nothing works.
RUN mkdir /tmp/xmlsec \
  && cd /tmp/xmlsec \
  && wget "http://www.aleksey.com/xmlsec/download/xmlsec1-1.2.26.tar.gz" \
  && tar zxf xmlsec1-1.2.26.tar.gz \
  && cd xmlsec1-1.2.26 \
  && ./configure \
        --prefix='/usr' \
        --enable-crypto-dl=no \
        --enable-pkgconfig \
  && make \
  && make install \
  && cd ${APP_HOME} \
  && rm -rf /tmp/xmlsec

RUN	echo 'export RBENV_ROOT=/usr/local/rbenv' > /etc/profile.d/rbenv.sh\
  &&  echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh\
  &&  echo 'export PATH="$RBENV_ROOT/shims:$PATH"' >> /etc/profile.d/rbenv.sh\
  &&  echo 'eval "$(rbenv init -)"'  >> /etc/profile.d/rbenv.sh\
  &&  chmod +x /etc/profile.d/rbenv.sh

RUN	git clone https://github.com/rbenv/rbenv.git ${RBENV_ROOT} \
  &&  mkdir -p ${RBENV_ROOT}/plugins \
  &&  git clone https://github.com/rbenv/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build \
  &&  git clone https://github.com/rbenv/rbenv-vars.git ${RBENV_ROOT}/plugins/rbenv-vars \
  &&  source /etc/profile.d/rbenv.sh

RUN	${RBENV_ROOT}/bin/rbenv install ${RBENV_VERSION} \
  &&  ${RBENV_ROOT}/shims/gem install passenger -v ${PASSENGER_VERSION} --no-ri --no-rdoc \
  &&  ${RBENV_ROOT}/shims/gem install bundler \
  &&  ${RBENV_ROOT}/shims/passenger-install-nginx-module --auto-download --auto --prefix=/opt/nginx \
  &&  ${RBENV_ROOT}/shims/passenger-config install-agent --auto \
  &&  ${RBENV_ROOT}/shims/passenger-config install-standalone-runtime --auto \
  &&  ${RBENV_ROOT}/bin/rbenv rehash

RUN	rm -rf /usr/local/rbenv/versions/${RBENV_VERSION}/lib/ruby/gems/${RBENV_DOCVERSION}/doc\
	/usr/local/rbenv/versions/${RBENV_VERSION}/lib/ruby/gems/${RBENV_DOCVERSION}/gems/passenger-${PASSENGER_VERSION}/doc \
/usr/local/rbenv/versions/${RBENV_VERSION}/share/

RUN npm install --global yarn

RUN \
  # Never use git:// because not everyone can use it.
  git config --global url."https://".insteadOf git:// \
  && git clone https://github.com/instructure/canvas-lms.git ${APP_HOME} \
  && git checkout ${CANVAS_VER} \
  && sed -i 's#1.16.4#1.16.5#' ./Gemfile.d/_before.rb \
  && ${RBENV_ROOT}/shims/bundle install --jobs 8 --path vendor/bundle \
  && yarn install --pure-lockfile \
  && for config in amazon_s3 database \
     delayed_jobs domain file_store outgoing_mail security external_migration; \
     do cp config/$config.yml.example config/$config.yml; done

RUN \
  rm -rf /opt/nginx/html && \
  ln -s ${APP_HOME}/public /opt/nginx/html

COPY config/*.yml /${APP_HOME}/config/

COPY entrypoint.sh /canvas-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/canvas-entrypoint.sh"]
