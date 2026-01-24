#!/bin/bash

# VPS Deployment Script
# Bu script VPS-də manual deployment üçün də istifadə oluna bilər

set -e

echo "Starting deployment..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="testing-app"
COMPOSE_FILE="docker-compose.yml"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

print_status "Docker found"

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

print_status "Docker Compose found"

# Stop existing containers
print_warning "Stopping existing containers..."
docker-compose down || docker compose down || true
print_status "Existing containers stopped"

# Remove old images (optional)
print_warning "Cleaning up old images..."
docker image prune -f
print_status "Old images cleaned up"

# Build new image
print_warning "Building new Docker image..."
docker-compose build --no-cache || docker compose build --no-cache
print_status "New image built successfully"

# Start containers
print_warning "Starting containers..."
docker-compose up -d || docker compose up -d
print_status "Containers started successfully"

# Wait for container to be healthy
print_warning "Waiting for application to start..."
sleep 5

# Check if container is running
if docker ps | grep -q $APP_NAME; then
    print_status "Container is running"
else
    print_error "Container failed to start. Check logs with: docker logs $APP_NAME"
    exit 1
fi

# Show logs
print_warning "Recent logs:"
docker logs $APP_NAME --tail 30

# Show container status
print_status "Container status:"
docker ps | grep $APP_NAME

echo ""
print_status "Deployment completed successfully!"
echo ""
echo "Access your application at: http://YOUR_VPS_IP"
echo "To view logs: docker logs -f $APP_NAME"
echo "To restart: docker-compose restart"
echo "To stop: docker-compose down"