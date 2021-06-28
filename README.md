# Canvas Local Environment

A production-like, **local** [canvas-lms](https://github.com/instructure/canvas-lms) environment.

## Requirements

1. Docker 19.03.1 (Docker for Mac, Docker for Windows)

## Getting Started

* Run `openssl req -newkey rsa:2048 -nodes -keyout certs/default.key -x509 -days 365 -out certs/default.crt` in Terminal or get someone to generate a SSL certificate and private key.
* Copy `.env.example` to `.env`. Add a complex password in the .env file.
* Run `docker compose up` in Terminal, PowerShell, Git-Bash or Docker Quickstart Terminal. This takes a long time to build canvas.
* Run the initial setup:
   * Get into the web container: `docker exec -ti canvas_web /bin/bash`
   * Run the initial setup: `RAILS_ENV=development bundle exec rake db:initial_setup'`
   * The initial setup will ask you to setup the admin email address and password.
* Modify your `/etc/hosts` file:
   * `localhost  web.internal mailhog.internal`
   * Clear your DNS cache: `dscachutil -flushcache` or `ipconfig \flushdns` or whatever it is on Windows.
* The following URLs should be up and running:
   * Canvas: https://web.internal
   * Mailhog: http://mailhog.internal
   * Traefik Dashboard: http://localhost:8080

## Other things

* Run delayed_jobs: `RAILS_ENV=development bundle exec ./script/delayed_job run`
