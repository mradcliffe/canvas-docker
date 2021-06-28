#!/bin/bash

# Check to see if swapfile exists.
if [ ! -d /swapfile ]; then
  fallocate -l 4G /swapfile && \
    mkswap /swapfile && \
    swapon /swapfile
fi

# Start nginx.
/opt/nginx/sbin/nginx -g "daemon on;"

RAILS_ENV=development \
CANVAS_BUILD_CONCURRENCY=2 \
USE_OPTIMIZED_JS=0 \
DISABLE_HAPPYPACK=1 \
COMPILE_ASSETS_STYLEGUIDE=0 \
COMPILE_ASSETS_API_DOCS=0 \
NODE_ENV=development \
  bundle exec rake canvas:compile_assets && \
  # This isn't working but it's working manually?
  # bundle exec ./scripts/canvas_init start && \
  # bundle exec rake brand_configs:generate_and_upload_all && \
  # RAILS_ENV=development bundle exec rake db:initial_setup && \
  # bundle exec rake assets:clobber && \
  # bundle exec rake assets:precompile && \
  # bundle exec rake db:migrate && \
  passenger start -p 4000 -e development --log-level 4
