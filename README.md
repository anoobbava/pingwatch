# PingWatch

A simple URL monitoring application built with Ruby on Rails, featuring Prometheus metrics and Kubernetes deployment.

## Features
- Simple URL monitoring without authentication
- Add and monitor public URLs
- Pings every 5 minutes (Sidekiq)
- Dashboard with uptime, last status, avg response time
- Prometheus /metrics endpoint
- Healthcheck at /health
- Kubernetes ready with minikube

## Prerequisites

### System Dependencies
- Ruby 3.0.6
- PostgreSQL
- Redis
- Node.js (for asset compilation)
- Docker (for building container images)
- kubectl
- minikube

### Install Dependencies

#### Ubuntu/Debian
```bash
# Install Ruby dependencies
sudo apt update
sudo apt install -y ruby ruby-dev ruby-bundler build-essential libpq-dev

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Install Redis
sudo apt install -y redis-server

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

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
brew install ruby postgresql redis node docker kubectl minikube
```

## Local Development Setup

### 1. Clone and Setup
```bash
git clone <repository-url>
cd pingwatch
bundle install
```

### 2. Database Setup
```bash
# Start PostgreSQL and Redis
sudo systemctl start postgresql
sudo systemctl start redis

# Create database
sudo -u postgres createdb pingwatch_development
sudo -u postgres createdb pingwatch_test

# Run migrations
bin/rails db:migrate
bin/rails db:seed
```

### 3. Environment Configuration
```bash
# Generate secret key
SECRET_KEY_BASE=$(openssl rand -hex 64)

# Set environment variables
export SECRET_KEY_BASE=$SECRET_KEY_BASE
export DATABASE_URL="postgresql://postgres@localhost/pingwatch_development"
export REDIS_URL="redis://localhost:6379/0"
```

### 4. Start Services
```bash
# Start Rails server
bin/rails server

# In another terminal, start Sidekiq
bundle exec sidekiq

# In another terminal, start Tailwind CSS watcher
bin/rails tailwindcss:watch
```

### 5. Access Application
- Main app: http://localhost:3000
- Health check: http://localhost:3000/health
- Metrics: http://localhost:3000/metrics

## Kubernetes Deployment with Minikube

### 1. Start Minikube
```bash
# Start minikube with sufficient resources
minikube start --driver=docker

# Enable addons
minikube addons enable ingress
minikube addons enable metrics-server

# Verify cluster is running
kubectl cluster-info
kubectl get nodes
```

### 2. Build and Load Docker Image
```bash
# Build the application image locally
docker build -t pingwatch:prod .

# Load image into minikube (for offline/limited connectivity scenarios)
minikube image load pingwatch:prod

# Alternative: If you have internet access, you can push to a registry
# docker tag pingwatch:prod your-registry/pingwatch:prod
# docker push your-registry/pingwatch:prod

# Verify image is available in minikube
minikube image ls | grep pingwatch
```

### 3. Deploy Application
```bash

kubectl apply -f k8s/base/ --recursive


OR one thing at a time
# Apply all Kubernetes resources
kubectl apply -f k8s/base/configmap.yaml
kubectl apply -f k8s/base/secrets.yaml
kubectl apply -f k8s/base/app/deployment.yaml
kubectl apply -f k8s/base/app/service.yaml
kubectl apply -f k8s/base/postgres/deployment.yaml
kubectl apply -f k8s/base/postgres/service.yaml
kubectl apply -f k8s/base/postgres/pvc.yaml
kubectl apply -f k8s/base/redis/deployment.yaml
kubectl apply -f k8s/base/redis/service.yaml
kubectl apply -f k8s/base/app/sidekiq-deployment.yaml
kubectl apply -f k8s/base/cronjobs/pingwatch-cron.yaml
```

### 4. Deploy Prometheus (Optional)
```bash
# Deploy Prometheus for monitoring
kubectl apply -f k8s/base/prometheus-config.yaml
kubectl apply -f k8s/base/prometheus-deployment.yaml
kubectl apply -f k8s/base/prometheus-service.yaml
```

### 5. Access the Application

#### Option A: Using NodePort (Recommended for Development)
```bash
# Apply the updated service with NodePort
kubectl apply -f k8s/base/app/service.yaml

# Get minikube IP
minikube ip

# Access the application directly
# Replace <minikube-ip> with the actual IP from minikube ip
curl http://<minikube-ip>:30080
# Or open in browser: http://<minikube-ip>:30080

# Access metrics
curl http://<minikube-ip>:30394/metrics
```

#### Option B: Using minikube service (with tunnel)
```bash
# This will create a tunnel and show you the local URLs
minikube service pingwatch

# Keep the terminal open - the tunnel will stay active
# Access via the provided URLs (e.g., http://127.0.0.1:41423)
# Press Ctrl+C to stop the tunnel when done
```



#### Option C: Using Port Forward (Simple but temporary)
```bash
# Port forward to access the application
kubectl port-forward service/pingwatch 3000:3000

# Access the application
curl http://localhost:3000
# Or open in browser: http://localhost:3000

# Keep terminal open - Ctrl+C to stop
```


### 6. Cleanup and Delete Services
```bash
# Delete all application resources
kubectl delete all,secrets,configmaps,pvc,pv,cronjobs --all


# Stop minikube completely
minikube stop
minikube delete
```

## Kubernetes Commands

### Pod Management
```bash
# Check pod status
kubectl get pods
kubectl get pods -o wide

# View pod logs
kubectl logs -f deployment/pingwatch
kubectl logs -f deployment/sidekiq
kubectl logs -f deployment/postgres

# Execute commands in pods
kubectl exec -it deployment/pingwatch -- bin/rails console
kubectl exec -it deployment/postgres -- psql -U postgres -d pingwatch_production
```

### Service Management
```bash
# Check services
kubectl get services
kubectl get endpoints

# Port forwarding
kubectl port-forward service/pingwatch 3000:3000
kubectl port-forward service/prometheus 9090:9090
```

### Deployment Management
```bash
# Check deployments
kubectl get deployments
kubectl describe deployment pingwatch

# Scale deployments
kubectl scale deployment pingwatch --replicas=2
kubectl scale deployment sidekiq --replicas=3

# Update deployment
kubectl set image deployment/pingwatch pingwatch=pingwatch:latest
kubectl rollout status deployment/pingwatch
```

### Database Operations
```bash
# Run migrations
kubectl exec -it deployment/pingwatch -- bin/rails db:migrate

# Reset database
kubectl exec -it deployment/pingwatch -- bin/rails db:drop db:create db:migrate

# Seed database
kubectl exec -it deployment/pingwatch -- bin/rails db:seed

# Access Rails console
kubectl exec -it deployment/pingwatch -- bin/rails console
```

### Monitoring and Debugging
```bash
# Check resource usage
kubectl top pods
kubectl top nodes

# View events
kubectl get events --sort-by='.lastTimestamp'

# Check persistent volumes
kubectl get pv,pvc

# View logs with timestamps
kubectl logs -f deployment/pingwatch --timestamps
```

## Troubleshooting

### Minikube Issues
```bash
# Reset minikube if having issues
minikube delete
minikube start --cpus=4 --memory=8192 --disk-size=20g

# Check minikube status
minikube status
minikube dashboard
```

### Pod Startup Issues
```bash
# Check pod events
kubectl describe pod <pod-name>

# Check pod logs
kubectl logs <pod-name>

# Check if secrets/configmaps exist
kubectl get secrets
kubectl get configmaps
```

### Database Connection Issues
```bash
# Check if PostgreSQL is running
kubectl get pods -l app=postgres

# Check PostgreSQL logs
kubectl logs -f deployment/postgres

# Test database connection
kubectl exec -it deployment/pingwatch -- bin/rails db:version
```

### Sidekiq Issues
```bash
# Check Sidekiq pods
kubectl get pods -l app=sidekiq

# Check Sidekiq logs
kubectl logs -f deployment/sidekiq

# Check Redis connection
kubectl exec -it deployment/redis -- redis-cli ping
```

### Image Pull Issues
```bash
# For offline/limited connectivity scenarios
# Build image locally and load into minikube
docker build -t pingwatch:prod .
minikube image load pingwatch:prod

# Verify image is loaded
minikube image ls | grep pingwatch

# For internet-connected scenarios
# Push to registry and pull in minikube
docker tag pingwatch:prod your-registry/pingwatch:prod
docker push your-registry/pingwatch:prod
# Update deployment to use registry image

# Check image pull status
kubectl describe pod <pod-name> | grep -A 10 Events
```

### Service Access Issues
```bash
# Check if service exists
kubectl get service pingwatch

# Check service endpoints
kubectl get endpoints pingwatch

# Check service type and ports
kubectl get service pingwatch -o yaml

# For NodePort access issues
kubectl get nodes -o wide
minikube ip



# Alternative: Use minikube service with tunnel
minikube service pingwatch
# Keep terminal open - tunnel will stay active until Ctrl+C
```

### Network Connectivity Issues
```bash
# Check if minikube can access external resources
kubectl run test-connectivity --image=busybox --rm -it --restart=Never -- nslookup google.com

# Test DNS resolution inside minikube
kubectl run dns-test --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default

# Check if minikube has internet access
kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -I https://google.com

# For offline scenarios, ensure all images are loaded locally
minikube image ls

# Load additional images if needed
minikube image load postgres:13
minikube image load redis:7
minikube image load prom/prometheus:latest
```

## Production Deployment

### Environment Variables
Create a `k8s/base/secrets.yaml` file with production secrets:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: pingwatch-secret
type: Opaque
data:
  SECRET_KEY_BASE: <base64-encoded-secret>
  POSTGRES_PASSWORD: <base64-encoded-password>
  REDIS_PASSWORD: <base64-encoded-password>
```

### Scaling
```bash
# Scale web application
kubectl scale deployment pingwatch --replicas=3

# Scale Sidekiq workers
kubectl scale deployment sidekiq --replicas=5

# Scale PostgreSQL (if using StatefulSet)
kubectl scale statefulset postgres --replicas=1
```

### Monitoring
- Prometheus metrics available at `/metrics`
- Health check endpoint at `/health`
- Use Prometheus and Grafana for monitoring
- Set up alerts for pod failures and high resource usage

## Service Access Methods

### Understanding Service Types
- **ClusterIP**: Internal access only (default)
- **NodePort**: External access via node IP + port (30000-32767)
- **Port Forward**: Temporary local access via kubectl

### Recommended Access Methods for Development

#### 1. NodePort (Best for Development)
```bash
# Service is already configured as NodePort
kubectl apply -f k8s/base/app/service.yaml

# Get minikube IP and access
MINIKUBE_IP=$(minikube ip)
echo "Access your app at: http://$MINIKUBE_IP:30080"
echo "Access metrics at: http://$MINIKUBE_IP:30394/metrics"
```

#### 2. minikube service (Convenient but requires tunnel)
```bash
# Creates tunnel automatically
minikube service pingwatch
# Keep terminal open - access via provided URLs
# Press Ctrl+C to stop tunnel
```

#### 2. kubectl port-forward (Simple temporary access)
```bash
# Forward local port to service
kubectl port-forward service/pingwatch 3000:3000
# Access at http://localhost:3000
# Keep terminal open - Ctrl+C to stop
```

## Quick Reference Commands

### Complete Deployment (Online)
```bash
minikube start --driver=docker
docker build -t pingwatch:prod .
docker push your-registry/pingwatch:prod
kubectl apply -f k8s/base/
# Access via NodePort: http://$(minikube ip):30080
# Or use: minikube service pingwatch
```

### Complete Deployment (Offline)
```bash
minikube start --driver=docker
docker build -t pingwatch:prod .
minikube image load pingwatch:prod
minikube image load postgres:13
minikube image load redis:7
kubectl apply -f k8s/base/
# Access via NodePort: http://$(minikube ip):30080
# Or use: minikube service pingwatch
```

### Complete Cleanup
```bash
kubectl delete -f k8s/base/
kubectl delete pvc --all
minikube stop
minikube delete
```

## Development Workflow

### Local Development
1. Make code changes
2. Test locally with `bin/rails server`
3. Run tests with `bin/rails test`
4. Commit changes

### Kubernetes Deployment
1. Build new Docker image: `docker build -t pingwatch:prod .`
2. Update deployment: `kubectl set image deployment/pingwatch pingwatch=pingwatch:prod`
3. Monitor rollout: `kubectl rollout status deployment/pingwatch`
4. Verify deployment: `kubectl get pods`

### Database Changes
1. Create migration: `bin/rails generate migration AddNewField`
2. Test locally: `bin/rails db:migrate`
3. Deploy to Kubernetes: `kubectl exec -it deployment/pingwatch -- bin/rails db:migrate`

---

## Recent Updates
- Removed Docker Compose references
- Added comprehensive Kubernetes/minikube setup
- Updated troubleshooting for Kubernetes environment
- Added production deployment guidelines
- Included monitoring and scaling instructions
