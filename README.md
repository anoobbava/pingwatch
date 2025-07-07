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

## Environment Variables

The application requires the following environment variables to be set:

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `SECRET_KEY_BASE` | Rails secret key for session encryption | Yes | - |
| `POSTGRES_PASSWORD` | PostgreSQL database password | Yes | - |
| `POSTGRES_USERNAME` | PostgreSQL database username | Yes | `postgres` |
| `DATABASE_NAME` | PostgreSQL database name | Yes | `pingwatch_production` |

### Security Notes
- Never commit your `.env` file to version control (it's already in `.gitignore`)
- Use strong, unique passwords for production environments
- Consider using a secrets management service for production deployments

## Running Locally with Docker Compose

1. **Set up environment variables:**
   ```sh
   # Create a .env file with required environment variables
   cat > .env << EOF
   # Rails secret key base (required for session encryption)
   SECRET_KEY_BASE=$(openssl rand -hex 64)
   
   # PostgreSQL database configuration
   POSTGRES_USERNAME=postgres
   POSTGRES_PASSWORD=your_secure_password_here
   DATABASE_NAME=pingwatch_production
   EOF
   ```

2. **Build and start all services:**
   ```sh
   docker-compose up --build
   ```

3. **Run database migrations:**
   ```sh
   docker-compose run --rm web bundle exec rails db:migrate
   ```

4. **(Optional) Seed the database:**
   ```sh
   docker-compose run --rm web bundle exec rails db:seed
   ```

5. **Visit [http://localhost:3001](http://localhost:3001)**

## Docker Commands

### Starting Services
```sh
# Start all services in background
docker-compose up -d

# Start all services with logs
docker-compose up

# Start specific service
docker-compose up -d web
docker-compose up -d db redis
```

### Stopping Services
```sh
# Stop all services
docker-compose down

# Stop and remove volumes (WARNING: This will delete all data)
docker-compose down -v

# Stop specific service
docker-compose stop web
docker-compose stop sidekiq
```

### Viewing Logs
```sh
# View all logs
docker-compose logs

# View logs for specific service
docker-compose logs web
docker-compose logs sidekiq
docker-compose logs db
docker-compose logs redis

# Follow logs in real-time
docker-compose logs -f web
docker-compose logs -f sidekiq

# View last N lines
docker-compose logs --tail=50 web
```

### Container Management
```sh
# Check container status
docker-compose ps

# Restart services
docker-compose restart
docker-compose restart web
docker-compose restart sidekiq

# Rebuild and restart
docker-compose up --build -d

# Execute commands in running containers
docker-compose exec web bundle exec rails console
docker-compose exec db psql -U postgres -d pingwatch_production
docker-compose exec redis redis-cli
```

### Database Operations
```sh
# Run migrations
docker-compose run --rm web bundle exec rails db:migrate

# Reset database
docker-compose run --rm web bundle exec rails db:drop db:create db:migrate

# Seed database
docker-compose run --rm web bundle exec rails db:seed

# Access Rails console
docker-compose run --rm web bundle exec rails console
```

### Monitoring and Debugging
```sh
# Check resource usage
docker stats

# View container details
docker-compose ps
docker inspect pingwatch_web_1

# Access container shell
docker-compose exec web bash
docker-compose exec sidekiq bash
```

## Troubleshooting

### Port Conflicts
If you get port binding errors, ensure your local PostgreSQL and Redis services are not running on ports 5432 and 6379. The app uses alternate ports (15432, 16379) to avoid conflicts.

### Permission Issues
If containers fail to start due to permission errors:
```sh
# Fix file permissions
sudo chown -R $(id -u):$(id -g) tmp log storage
sudo chmod -R 777 tmp log storage
sudo chmod 644 config/master.key
```

### Database Issues
If you encounter database errors:
```sh
# Reset the database
docker-compose down
docker-compose up -d db redis
docker-compose run --rm web bundle exec rails db:drop db:create db:migrate
docker-compose up -d
```

### Container Won't Start
```sh
# Check logs for errors
docker-compose logs web

# Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Missing Environment Variables
If you get errors about missing environment variables:
```sh
# Check if .env file exists
ls -la .env

# Create .env file if missing
cat > .env << EOF
SECRET_KEY_BASE=$(openssl rand -hex 64)
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=your_secure_password_here
DATABASE_NAME=pingwatch_production
EOF
```

### Docker Compose 'ContainerConfig' Error
If you encounter `KeyError: 'ContainerConfig'` when running `docker-compose up --build`:
```sh
# Clean up Docker system
docker system prune -f

# Remove all containers and volumes
docker-compose down -v

# Rebuild from scratch
docker-compose build --no-cache

# Start services
docker-compose up -d

# Run migrations (if needed)
docker-compose run --rm web bundle exec rails db:migrate
```

This error typically occurs due to corrupted Docker images or containers and requires a complete cleanup and rebuild.

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

## Recent Fixes Applied
- Fixed database migrations to remove user references (app doesn't use authentication)
- Added proper .env file setup for SECRET_KEY_BASE
- Fixed file permissions for Docker containers
- Disabled force_ssl for local development
- Fixed stylesheet references in application layout
- Updated docker-compose.yml with correct environment variables
- Changed web server port from 3000 to 3001
- Added comprehensive Docker commands documentation

---
