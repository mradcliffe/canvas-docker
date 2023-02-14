# Canvas Local Environment

A production-like, **local** [canvas-lms](https://github.com/instructure/canvas-lms) environment.


## Requirements

1. Docker (Docker for Mac, Docker for Windows, docker-ce)

## Getting Started

1. Generate a SSL certificate using `openssl`:
   * Run `openssl req -newkey rsa:2048 -nodes -keyout certs/default.key -x509 -days 365 -out certs/default.crt`.
   * (Windows) This is available in an Ubuntu machine running on Windows Subsystem for Linux 2.
2. Copy `.env.example` to `.env`.
   a. Set a password that adheres to Canvas LMS password requirements (8 length minimum with number and non-alphanumeric character).
   b. Add a 20-character encryption key. You can use a password generator like `pwgen`.
   c. Configure any port mapping in case you have port 80, 443, 8080 or 8025 in-use locally.
      This is mainly only useful for `TRAEFIK_PORT` or `MAILHOG_PORT` and not supported for nginx.
3. Run `docker-compose up` in Terminal, PowerShell, Git-Bsh or Docker Quickstart Terminal.
   * This will take a while to run Canvas LMS rake command as it builds a plethora of front-end frameworks.
4. Run the initial setup:
   a. Get into the web container: `docker exec -ti canvas_web /bin/bash`
   b. Run the initial setup: `RAILS_ENV=development bundle exec rake db:initial_setup`
5. Update and clear your DNS cache:
   a. Modify your `/etc/hosts` file with an additional line at the bottom: `localhost canvas.internal db.canvas.internal`
   b. Clear your DNS cache: `dscacheutil -flushcache` or `ipconfig \flushdns` or whatever it is on Windows.
6. The following URLs should be up and running with the appropriate ports configured in 2c above:
   * Canvas: https://canvas.internal
   * Mailhog: http://canvas.internal:8025
   * Traefik Dashboard: http://localhost:8080

## Other things

* Run delayed_jobs: `RAILS_ENV=development bundle exec ./script/delayed_job run`

## Images

* Build and publish canvas/Dockerfile as `mradcliffe2/docker-canvas-web`

## License

This docker and docker-compsoe suite is licensed under the [MIT License](./LICENSE) as it does not include code from Canvas LMS. However please note any changes to Canvas LMS must be done under the [Instructure Canvas LMS AGPL](https://github.com/instructure/canvas-lms/blob/master/LICENSE).
