# PingWatch

A comprehensive URL monitoring application built with Ruby on Rails, featuring Prometheus metrics, Grafana dashboards, and Kubernetes deployment with minikube.

## Features
- **URL Monitoring**: Monitor public URLs with configurable intervals
- **Real-time Metrics**: Prometheus integration for comprehensive monitoring
- **Beautiful Dashboards**: Grafana dashboards for visualization
- **Background Processing**: Sidekiq for reliable job processing
- **Kubernetes Ready**: Complete minikube deployment setup
- **Health Checks**: Built-in health monitoring endpoints
- **Load Testing**: Built-in tools for generating test data and load

## Architecture Overview

### Components
- **Rails App**: Main web application with monitoring logic
- **Sidekiq**: Background job processor for URL pinging
- **PostgreSQL**: Primary database for storing URLs and results
- **Redis**: Message broker for Sidekiq
- **Prometheus**: Metrics collection and storage
- **Grafana**: Metrics visualization and dashboards
- **Prometheus Exporter**: Rails metrics exporter

### Data Flow
1. **URL Monitoring**: Sidekiq jobs ping URLs every 5 minutes
2. **Metrics Collection**: Prometheus scrapes Rails app at `/metrics`
3. **Data Storage**: Results stored in PostgreSQL, metrics in Prometheus
4. **Visualization**: Grafana queries Prometheus for dashboard data

## Prerequisites

### System Requirements
- **OS**: Linux, macOS, or Windows with WSL2
- **Memory**: Minimum 8GB RAM (16GB recommended)
- **Storage**: 20GB free space
- **CPU**: 4 cores minimum

### Required Software
- **Docker**: For building and running containers
- **kubectl**: Kubernetes command-line tool
- **minikube**: Local Kubernetes cluster
- **Ruby 3.0.6+**: For local development (optional)

## Installation

### 1. Install Dependencies

#### Ubuntu/Debian
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

#### macOS
```bash
# Install Homebrew if not installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install docker kubectl minikube

# Start Docker Desktop
open /Applications/Docker.app
```

#### Windows (WSL2)
```bash
# Install Docker Desktop for Windows first
# Then in WSL2:
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### 2. Clone Repository
```bash
git clone <repository-url>
cd pingwatch
```

## Quick Start (Complete Deployment)

### 1. Start Minikube
```bash
# Start minikube with sufficient resources
minikube start --driver=docker --cpus=4 --memory=8192 --disk-size=20g

# Enable required addons
minikube addons enable ingress
minikube addons enable metrics-server

# Verify cluster is running
kubectl cluster-info
kubectl get nodes
```

### 2. Build and Deploy
```bash
# Build the application image
docker build -t pingwatch:prod .

# Load image into minikube
minikube image load pingwatch:prod

# Deploy all components
kubectl apply -f k8s/base/ --recursive

# Wait for all pods to be ready
kubectl wait --for=condition=ready pod --all --timeout=300s
```

### 3. Access Applications
```bash
# Get minikube IP
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"

# Access applications via port-forward
kubectl port-forward service/pingwatch 3000:80 &
kubectl port-forward service/grafana 3001:3000 &
kubectl port-forward service/prometheus 3002:9090 &

# Access URLs:
# Main App: http://localhost:3000
# Grafana: http://localhost:3001 (admin/admin123)
# Prometheus: http://localhost:3002
```

### 4. Generate Test Data
```bash
# Populate with test data
kubectl exec -it deployment/pingwatch -- bin/rails grafana:populate_data

# Start continuous load generation
kubectl exec -it deployment/pingwatch -- bin/rails grafana:generate_load
```

## Complete Destroy and Recreate Commands

### Full Cleanup
```bash
# Stop all port forwards
pkill -f "kubectl port-forward"

# Delete all Kubernetes resources
kubectl delete -f k8s/base/ --recursive --ignore-not-found=true
kubectl delete pvc --all --ignore-not-found=true
kubectl delete pv --all --ignore-not-found=true
kubectl delete secrets --all --ignore-not-found=true
kubectl delete configmaps --all --ignore-not-found=true

# Stop and delete minikube cluster
minikube stop
minikube delete

# Remove Docker images (optional)b
docker rmi pingwatch:prod --force
```

### Complete Recreate
```bash
# Start fresh minikube
minikube start --driver=docker --cpus=4 --memory=8192 --disk-size=20g
minikube addons enable ingress
minikube addons enable metrics-server

# Build and deploy
docker build -t pingwatch:prod .
minikube image load pingwatch:prod
kubectl apply -f k8s/base/ --recursive

# Wait for deployment
kubectl wait --for=condition=ready pod --all --timeout=300s

# Setup port forwarding
kubectl port-forward service/pingwatch 3000:80 &
kubectl port-forward service/grafana 3001:3000 &
kubectl port-forward service/prometheus 3002:9090 &

# Generate test data
kubectl exec -it deployment/pingwatch -- bin/rails grafana:populate_data
```

## Load Testing and Data Generation

### Available Rake Tasks
```bash
# Populate with test data (one-time)
kubectl exec -it deployment/pingwatch -- bin/rails grafana:populate_data

# Generate continuous load
kubectl exec -it deployment/pingwatch -- bin/rails grafana:generate_load

# Clear all test data
kubectl exec -it deployment/pingwatch -- bin/rails grafana:clear_data

# Show current statistics
kubectl exec -it deployment/pingwatch -- bin/rails grafana:stats
```

### What the Load Generator Does
1. **Creates Test URLs**: Google, GitHub, Stack Overflow, HTTPBin endpoints
2. **Generates Sidekiq Jobs**: 1000 background jobs for URL pinging
3. **Creates Ping Results**: 50 historical ping results with varied scenarios
4. **Simulates HTTP Traffic**: 200 HTTP requests to generate Rails metrics
5. **Continuous Load**: Ongoing job generation and HTTP traffic

## Monitoring Stack

### Prometheus Configuration
- **Scraping**: Collects metrics from Rails app at `/metrics` endpoint
- **Storage**: Time-series database for metrics retention
- **Targets**: 
  - Rails application metrics
  - Sidekiq job metrics
  - System resource metrics

### Grafana Dashboards
- **URL Monitoring**: Uptime, response times, error rates
- **System Metrics**: CPU, memory, disk usage
- **Sidekiq Metrics**: Job processing rates, queue sizes
- **HTTP Metrics**: Request rates, response times, error rates

### Metrics Endpoints
- **Application**: `http://localhost:3000/metrics`
- **Health Check**: `http://localhost:3000/health`
- **Grafana**: `http://localhost:3001` (admin/admin123)
- **Prometheus**: `http://localhost:3002`

## Kubernetes Management

### Pod Management
```bash
# Check pod status
kubectl get pods -o wide

# View logs
kubectl logs -f deployment/pingwatch
kubectl logs -f deployment/sidekiq
kubectl logs -f deployment/grafana
kubectl logs -f deployment/prometheus

# Execute commands in pods
kubectl exec -it deployment/pingwatch -- bin/rails console
kubectl exec -it deployment/pingwatch -- bin/rails db:migrate
```

### Service Management
```bash
# Check services
kubectl get services

# Port forwarding
kubectl port-forward service/pingwatch 3000:80
kubectl port-forward service/grafana 3001:3000
kubectl port-forward service/prometheus 3002:9090
```

### Scaling
```bash
# Scale web application
kubectl scale deployment pingwatch --replicas=3

# Scale Sidekiq workers
kubectl scale deployment sidekiq --replicas=5

# Check resource usage
kubectl top pods
kubectl top nodes
```

## Troubleshooting

### Common Issues

#### Minikube Won't Start
```bash
# Reset minikube
minikube delete
minikube start --driver=docker --cpus=4 --memory=8192 --disk-size=20g

# Check system resources
free -h
df -h
```

#### Pods Not Starting
```bash
# Check pod events
kubectl describe pod <pod-name>

# Check pod logs
kubectl logs <pod-name>

# Check if images are loaded
minikube image ls | grep pingwatch
```

#### Database Connection Issues
```bash
# Check PostgreSQL pod
kubectl get pods -l app=postgres

# Check database logs
kubectl logs -f deployment/postgres

# Run migrations
kubectl exec -it deployment/pingwatch -- bin/rails db:migrate
```

#### Sidekiq Issues
```bash
# Check Sidekiq pods
kubectl get pods -l app=sidekiq

# Check Sidekiq logs
kubectl logs -f deployment/sidekiq

# Check Redis connection
kubectl exec -it deployment/redis -- redis-cli ping
```

### Debugging Commands
```bash
# Check all resources
kubectl get all

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Check persistent volumes
kubectl get pv,pvc

# Check secrets and configmaps
kubectl get secrets,configmaps
```

## Development Workflow

### Local Development
```bash
# Start minikube
minikube start --driver=docker

# Build and deploy
docker build -t pingwatch:prod .
minikube image load pingwatch:prod
kubectl apply -f k8s/base/ --recursive

# Setup port forwarding
kubectl port-forward service/pingwatch 3000:80 &
kubectl port-forward service/grafana 3001:3000 &

# Generate test data
kubectl exec -it deployment/pingwatch -- bin/rails grafana:populate_data
```

### Code Changes
```bash
# After making code changes
docker build -t pingwatch:prod .
minikube image load pingwatch:prod
kubectl rollout restart deployment/pingwatch
kubectl rollout status deployment/pingwatch
```

### Database Changes
```bash
# Create migration locally
bin/rails generate migration AddNewField

# Apply to Kubernetes
kubectl exec -it deployment/pingwatch -- bin/rails db:migrate
```

## Production Considerations

### Security
- Change default passwords in `k8s/base/secrets.yaml`
- Use proper SSL certificates
- Implement network policies
- Regular security updates

### Scaling
- Use Horizontal Pod Autoscaler (HPA)
- Configure resource limits and requests
- Use persistent volumes for data
- Implement proper backup strategies

### Monitoring
- Set up alerting rules in Prometheus
- Configure Grafana alerts
- Monitor resource usage
- Set up log aggregation

## Quick Reference

### Essential Commands
```bash
# Start everything
minikube start --driver=docker --cpus=4 --memory=8192
docker build -t pingwatch:prod .
minikube image load pingwatch:prod
kubectl apply -f k8s/base/ --recursive
kubectl port-forward service/pingwatch 3000:80 &
kubectl port-forward service/grafana 3001:3000 &
kubectl exec -it deployment/pingwatch -- bin/rails grafana:populate_data

# Stop everything
kubectl delete -f k8s/base/ --recursive
minikube stop
minikube delete

# Check status
kubectl get pods
kubectl get services
kubectl logs -f deployment/pingwatch
```

### Access URLs
- **Main App**: http://localhost:3000
- **Grafana**: http://localhost:3001 (admin/admin123)
- **Prometheus**: http://localhost:3002
- **Health Check**: http://localhost:3000/health
- **Metrics**: http://localhost:3000/metrics

---

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review pod logs: `kubectl logs -f deployment/pingwatch`
3. Check events: `kubectl get events --sort-by='.lastTimestamp'`
4. Verify minikube status: `minikube status`
