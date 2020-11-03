# Canvas Environment

A local canvas environment.

## Requirements

1. Docker 18.06.1-ce (Docker for Mac, Docker for Windows or Docker ToolBox)

## Getting Started

* Run `openssl req -newkey rsa:2048 -nodes -keyout certs/default.key -x509 -days 365 -out certs/default.crt` in Terminal or get someone to generate a SSL certificate and private key.
* Run `docker-compose up` in Terminal, Git-Bash or Docker Quickstart Terminal. This takes a long time to build canvas.
* Run the initial setup:
   * Get into the web container: `docker exec -ti canvas_web_ /bin/bash`
   * Run the initial setup: `RAILS_ENV=development ${RBENV_ROOT}/shims/bundle exec rake db:initial_setup'`
   * The initial setup will ask you to setup the admin email address and password.
* Modify your `/etc/hosts` file:
   * `localhost  web.internal mailhog.internal`
   * Clear your DNS cache: `dscachutil -flushcache` or `ipconfig \flushdns` or whatever it is on Windows.
* The following URLs should be up and running:
   * Canvas: https://web.internal
   * Mailhog: http://mailhog.internal
   * Traefik Dashboard: http://localhost:8080

## Other things

* Run delayed_jobs: `RAILS_ENV=development ${RBENV_ROOT}/shims/bundle exec ./script/delayed_job run`

