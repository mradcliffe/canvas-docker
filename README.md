# Canvas Environment

A local canvas environment.

## Requirements

1. Docker 18.06.1-ce (Docker for Mac, Docker for Windows or Docker ToolBox)

## Getting Started

* Run `docker-compose up` in Terminal, Git-Bash or Docker Quickstart Terminal. This takes a long time to build canvas.
* Run `docker exec -e RAILS_ENV=development canvas-docker_web_1 sh -c '${RBENV_ROOT}/shims/bundle exec rake db:initial_setup'` to install database tables.  This may not work with docker exec so as an alternative run the following:
   * Get into the web container: `docker exec -ti canvas-docker_web_1 /bin/bash`
   * Run the initial setup: `RAILS_ENV=development ${RBENV_ROOT}/shims/bundle exec rake db:initial_setup'`
   * The initial setup will ask you to setup the admin email address and password.
* Modify your `/etc/hosts` file:
   * `localhost  web.internal mailhog.internal`
   * Clear your DNS cache: `dscachutil -flushcache` or `ipconfig \flushdns` or whatever it is on Windows.
* The following URLs should be up and running:
   * Canvas: http://web.internal
   * Mailhog: http://mailhog.internal
   * Traefik Dashboard: http://localhost:8080

