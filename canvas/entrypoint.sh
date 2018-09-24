#!/bin/bash

# Check to see if swapfile exists.
if [ ! -d /swapfile ]; then
  fallocate -l 4G /swapfile && \
    mkswap /swapfile && \
    swapon /swapfile
fi

RAILS_ENV=development \
CANVAS_BUILD_CONCURRENCY=2 \
USE_OPTIMIZED_JS=0 \
DISABLE_HAPPYPACK=1 \
COMPILE_ASSETS_STYLEGUIDE=0 \
COMPILE_ASSETS_API_DOCS=0 \
NODE_ENV=development \
  ${RBENV_ROOT}/shims/bundle exec rake canvas:compile_assets && \
  # This isn't working but it's working manually?
  # ${RBENV_ROOT}/shims/bundle exec ./scripts/canvas_init start && \
  #RAILS_ENV=development ${RBENV_ROOT}/shims/bundle exec rake brand_configs:generate_and_upload_all && \
  #RAILS_ENV=development ${RBENV_ROOT}/shims/bundle exec rake db:initial_setup && \
  #${RBENV_ROOT}/shims/bundle exec rake assets:clobber && \
  #${RBENV_ROOT}/shims/bundle exec rake assets:precompile && \
  #${RBENV_ROOT}/shims/bundle exec rake db:migrate && \
  /usr/local/rbenv/shims/passenger start -p 80 -e development --log-level 4
