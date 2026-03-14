# README

This application is a Ruby on Rails API designed to ingest and query people records coming from external systems. The application is containerized using Docker and orchestrated with docker-compose. Common development commands are exposed through a Makefile for convenience.

Things you may want to cover:

* Ruby version

Ruby 3.2.8
Rails 7.2.0

The application runs inside Docker containers, so installing Ruby locally is not required.

* System dependencies

The application depends on the following services:

- PostgreSQL (primary database)
- Redis (caching and future background job support)
- Docker
- Docker Compose
- Make

Make sure Docker, Docker Compose and Make are installed on your machine before running the application.

* Configuration

Application services are configured through `docker-compose.yml`.

The main containers used are:

- `backend` – Rails API application
- `db` – PostgreSQL database
- `redis` – Redis service
- `frontend` – frontend container (if applicable)

Environment variables can be configured through docker-compose or environment files if needed.

* Database creation or Database initialization

run the `db.init` Make command which creates the database, runs migrations, and loads seed data.

* How to run the test suite

Run the full RSpec test suite:

run the `rspec FILE={path}` Make command. `FILE={path}` is optional

* Services (job queues, cache servers, search engines, etc.)

The application currently uses the following services:

- PostgreSQL for persistent storage
- Redis for caching and potential background job processing

All services are defined in `docker-compose.yml` and run inside Docker containers.

* Development commands

Common development tasks are available through the Makefile. running `make {command}`

Build Docker images.(Or Installing new gems.):

`images.build`

Installing new gems.Start all services:

`make start`

Stop all services:

`make stop`

Open a Rails console:

`make rails.c`

Open a shell inside the backend container:

`make sh`

Update gems:

`make bundle.update`

Run RuboCop:

`make rubocop`

Auto-fix RuboCop issues:

`make rubocop.autofix`
