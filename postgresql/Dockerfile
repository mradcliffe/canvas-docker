FROM postgres:9.6.10-alpine

RUN apk add --no-cache -t .postgres-run-deps \
  ca-certificates \
  build-base gcc make \
  icu-dev \
  postgresql-dev "postgresql-contrib" \
  py-pip \
  unzip \
  && pip install pgxnclient

ENV PG_COLLKEY_VERSION 0.5.1

RUN pgxnclient download --yes --target ~ pg_collkey=${PG_COLLKEY_VERSION} \
  && unzip ~/pg_collkey-${PG_COLLKEY_VERSION}.zip -d ~/ \
  && cd ~/pg_collkey-${PG_COLLKEY_VERSION} \
  && mv Makefile Makefile.orig \
  && sed '/^DATA = \$(wildcard/d' Makefile.orig > Makefile \
  && make \
  && make install

