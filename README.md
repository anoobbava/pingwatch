# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

# PingWatch

## Features
- Simple URL monitoring without authentication
- Add and monitor public URLs
- Pings every 5 minutes (Sidekiq)
- Dashboard with uptime, last status, avg response time
- Prometheus /metrics endpoint
- Healthcheck at /healthcheck
- Docker & K8s ready

## Running Locally with Docker Compose

1. Build and start all services:
   ```sh
   docker-compose up --build
   ```
2. Set a secret key base (first time only):
   ```sh
   export SECRET_KEY_BASE=$(docker-compose run --rm web bundle exec rake secret)
   ```
3. Run database migrations:
   ```sh
   docker-compose run --rm web rails db:migrate
   ```
4. (Optional) Seed the database:
   ```sh
   docker-compose run --rm web rails db:seed
   ```
5. Visit [http://localhost:3000](http://localhost:3000)

## Scheduling Pings
- Use cron or a scheduler to run:
  ```sh
  docker-compose run --rm web rails pingwatch:ping_all
  ```
  every 5 minutes.

## Kubernetes Readiness
- All secrets and DB config are externalized via env vars.
- Healthcheck: `/healthcheck`
- Prometheus metrics: `/metrics`
- Use a K8s CronJob for periodic pings.

---
