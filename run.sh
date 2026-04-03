#!/usr/bin/env bash
set -e

echo "Starting Notification Preferences API..."

# Copy env file if not present
if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example"
fi

# Build and start all services
docker-compose up -d --build

echo "Waiting for services to be healthy..."
sleep 10

# Check health
echo "Checking app health..."
for i in $(seq 1 12); do
  if curl -sf http://localhost:8000/health > /dev/null 2>&1; then
    echo "App is healthy!"
    echo ""
    echo "Services running:"
    docker-compose ps
    echo ""
    echo "API available at: http://localhost:8000"
    echo "Health check:     http://localhost:8000/health"
    echo "API docs:         http://localhost:8000/docs"
    exit 0
  fi
  echo "  Waiting... ($i/12)"
  sleep 5
done

echo "ERROR: App did not become healthy in time."
docker-compose logs app
exit 1
