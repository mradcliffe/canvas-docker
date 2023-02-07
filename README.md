# Canvas Local Environment

A production-like, **local** [canvas-lms](https://github.com/instructure/canvas-lms) environment.


## Requirements

1. Docker (Docker for Mac, Docker for Windows, docker-ce)

## Getting Started

* Run `openssl req -newkey rsa:2048 -nodes -keyout certs/default.key -x509 -days 365 -out certs/default.crt` in Terminal or get someone to generate a SSL certificate and private key.
   * (Windows) This is available in an Ubuntu machine running on Windows Subsystem for Linux 2.
* Copy `.env.example` to `.env`. Add a complex password in the .env file and add a 20-character encryption key (use a password generator).
* Run `docker compose up` in Terminal, PowerShell, Git-Bash or Docker Quickstart Terminal. This takes a long time to build canvas.
   * Note the canvas docker image will take forever to build AND it will take forever to spin up as the plethora of canvas' front-end frameworks are built.
* Run the initial setup:
   * Get into the web container: `docker exec -ti canvas_web /bin/bash`
   * Run the initial setup: `RAILS_ENV=development bundle exec rake db:initial_setup`
* Modify your `/etc/hosts` file:
   * `localhost canvas.internal db.canvas.internal`
   * Clear your DNS cache: `dscachutil -flushcache` or `ipconfig \flushdns` or whatever it is on Windows.
* The following URLs should be up and running:
   * Canvas: https://canvas.internal
   * Mailhog: http://canvas.internal:8025
   * Traefik Dashboard: http://localhost:8080

## Other things

* Run delayed_jobs: `RAILS_ENV=development bundle exec ./script/delayed_job run`

## Images

* Build and publish canvas/Dockerfile as `mradcliffe2/docker-canvas-web`

## License

This docker and docker-compsoe suite is licensed under the [MIT License](./LICENSE) as it does not include code from Canvas LMS. However please note any changes to Canvas LMS must be done under the [Instructure Canvas LMS AGPL](https://github.com/instructure/canvas-lms/blob/master/LICENSE).
