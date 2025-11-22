# Docker Setup & Verification Guide

Complete step-by-step instructions to run and verify the Grocery App with Docker & Docker Compose.

## Prerequisites

Ensure you have installed:
- **Docker** (v20.10+): https://docs.docker.com/get-docker/
- **Docker Compose** (v2.0+): https://docs.docker.com/compose/install/
- **Git** (for cloning the repo)

### Verify Installation

```bash
docker --version
docker-compose --version
```

Expected output:
```
Docker version 24.x.x
Docker Compose version 2.x.x
```

---

## Step 1: Clone & Setup Environment

```bash
# Clone the repository
git clone https://github.com/MrCarpediem/grocery-app.git
cd grocery-app

# Copy environment template
cp .env.example .env
```

### Edit `./env` File

Open `.env` in your editor and update these values:

```env
# MongoDB credentials
MONGO_USER=admin
MONGO_PASSWORD=password

# JWT Secret (change this to a random string)
JWT_SECRET=your_super_secret_jwt_key_12345

# Cloudinary (optional, leave empty if not using)
CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret

# Seller settings
SELLER_EMAIL=seller@example.com

# Stripe (optional)
STRIPE_SECRET_KEY=sk_test_your_stripe_key

# Frontend API URL
VITE_API_URL=http://localhost:5000
```

**Important:** Change `JWT_SECRET` to a random secure string in production.

---

## Step 2: Start Services

### Build and Start All Containers

```bash
# Pull latest images and build custom images
docker-compose up -d

# This will:
# - Download MongoDB 7 image
# - Build backend Docker image
# - Build frontend Docker image (with Nginx)
# - Start all 3 services: mongodb, backend, frontend
```

### Wait for Services to Be Ready

```bash
# Check service status
docker-compose ps
```

Expected output:
```
NAME                   COMMAND                  SERVICE      STATUS
grocery-backend        "dumb-init -- node i…"   backend      Up 10 seconds (healthy)
grocery-frontend       "nginx -g daemon off…"   frontend     Up 8 seconds
grocery-mongodb        "mongod"                 mongodb      Up 12 seconds (healthy)
```

**All services should show `Up` status. MongoDB and backend should show `(healthy)`.**

Wait ~30 seconds for MongoDB and backend to fully initialize.

---

## Step 3: Verify Services Are Running

### 3.1 Check Docker Logs

```bash
# View backend logs
docker-compose logs backend

# Expected: "Server is running on port 5000"
```

```bash
# View MongoDB logs
docker-compose logs mongodb

# Expected: "waiting for connections on port 27017"
```

```bash
# View frontend logs
docker-compose logs frontend

# Expected: No errors, nginx should be running quietly
```

### 3.2 Verify Network Connectivity

```bash
# Check if containers can communicate
docker-compose exec backend ping mongodb

# Expected: "64 bytes from 172.x.x.x: seq=0 ttl=64 time=x.xxx ms"
```

---

## Step 4: Test API Endpoints

### 4.1 Test Backend is Running

```bash
# From your host machine
curl http://localhost:5000/api/product/list

# Expected response (JSON array of products):
# []
```

### 4.2 Test User Registration

```bash
curl -X POST http://localhost:5000/api/user/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123"
  }' \
  -c cookies.txt

# Expected response:
# {"success":true,"message":"User registered successfully"}
```

### 4.3 Test User Login

```bash
curl -X POST http://localhost:5000/api/user/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }' \
  -c cookies.txt

# Expected response (with token in cookie):
# {"success":true,"message":"Login successful"}
```

### 4.4 Test Authentication

```bash
# Check if user is authenticated
curl -b cookies.txt http://localhost:5000/api/user/is-auth

# Expected response:
# {"success":true,"authenticated":true,"user":"..."}
```

### 4.5 Test Seller Login

```bash
curl -X POST http://localhost:5000/api/seller/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "seller@example.com",
    "password": "seller_password"
  }' \
  -c seller_cookies.txt

# Check seller auth (make sure email matches SELLER_EMAIL in .env)
curl -b seller_cookies.txt http://localhost:5000/api/seller/is-auth
```

---

## Step 5: Test Frontend (React App)

### 5.1 Access the Web App

Open your browser and navigate to:
```
http://localhost
```

You should see the grocery app homepage with:
- Navigation bar
- Product listing
- Category filters
- Shopping cart icon
- Login/Register modal

### 5.2 Test Frontend → Backend Communication

1. **Open browser DevTools** (F12 or Cmd+Option+I)
2. **Go to Console tab**
3. **Register a new user:**
   - Click "Login" button
   - Fill in the registration form
   - Verify in DevTools that API calls to `/api/user/register` succeed (Network tab)

4. **Check cookies:**
   - Open DevTools → Application → Cookies
   - You should see `token` cookie set by the backend

---

## Step 6: Test Database Connection

### 6.1 Connect to MongoDB Container

```bash
# Access MongoDB shell
docker-compose exec mongodb mongosh \
  --username admin \
  --password password \
  --authenticationDatabase admin

# Inside the MongoDB shell:
> use grocery-app
> show collections
> db.users.find()
```

Expected output: You should see the user you just registered.

### 6.2 Verify Data Persistence

```bash
# Stop containers
docker-compose stop

# Start them again
docker-compose start

# Data should still exist because MongoDB uses a volume
docker-compose exec mongodb mongosh \
  --username admin \
  --password password \
  --authenticationDatabase admin -c "use grocery-app; db.users.count()"
```

---

## Step 7: Test File Uploads

### 7.1 Add a Product (as Seller)

```bash
# Login as seller first
curl -X POST http://localhost:5000/api/seller/login \
  -H "Content-Type: application/json" \
  -d '{"email":"seller@example.com","password":"seller_password"}' \
  -c seller_cookies.txt

# Add a product with image
curl -X POST http://localhost:5000/api/product/add-product \
  -b seller_cookies.txt \
  -F "name=Apples" \
  -F "price=50" \
  -F "category=Fruits" \
  -F "stock=100" \
  -F "image=@/path/to/image.jpg"

# Expected: Product created successfully
```

### 7.2 Verify Uploads

```bash
# Check uploads folder in backend container
docker-compose exec backend ls -la /app/uploads

# Expected: You should see image files

# Access uploaded image via HTTP
curl http://localhost/images/filename.jpg > downloaded_image.jpg
```

---

## Step 8: Run Complete End-to-End Test

### Test Scenario: User Registers, Adds to Cart, and Places Order

```bash
#!/bin/bash

API="http://localhost:5000/api"

echo "=== 1. Register User ==="
curl -X POST $API/user/register \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@test.com","password":"pass123"}' \
  -c cookies.txt -s | jq

echo -e "\n=== 2. Login User ==="
curl -X POST $API/user/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@test.com","password":"pass123"}' \
  -b cookies.txt -c cookies.txt -s | jq

echo -e "\n=== 3. Get Products ==="
curl $API/product/list -s | jq

echo -e "\n=== 4. Add Address ==="
curl -X POST $API/address/add \
  -H "Content-Type: application/json" \
  -b cookies.txt \
  -d '{
    "firstName":"John",
    "lastName":"Doe",
    "email":"john@test.com",
    "street":"123 Main St",
    "city":"New York",
    "state":"NY",
    "zipcode":"10001",
    "country":"USA",
    "phone":"555-1234"
  }' -s | jq

echo -e "\n=== 5. Update Cart ==="
curl -X POST $API/cart/update \
  -H "Content-Type: application/json" \
  -b cookies.txt \
  -d '{"items":[{"productId":"product_id_here","quantity":2}]}' -s | jq

echo -e "\n=== 6. Check Auth ==="
curl $API/user/is-auth -b cookies.txt -s | jq

echo -e "\n=== All tests completed ==="
```

Save this as `test-e2e.sh` and run:
```bash
chmod +x test-e2e.sh
./test-e2e.sh
```

---

## Troubleshooting

### Problem: Containers won't start

```bash
# Check detailed logs
docker-compose logs

# Rebuild from scratch
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Problem: Port 80 or 5000 already in use

Edit `docker-compose.yml` and change ports:
```yaml
frontend:
  ports:
    - "8080:80"  # Changed from 80:80

backend:
  ports:
    - "5001:5000"  # Changed from 5000:5000
```

Then access frontend at `http://localhost:8080`

### Problem: MongoDB connection failed

```bash
# Check MongoDB logs
docker-compose logs mongodb

# Verify credentials in .env match docker-compose.yml
# Restart MongoDB
docker-compose restart mongodb
docker-compose logs mongodb  # Wait for "waiting for connections"
```

### Problem: Frontend shows "Cannot connect to API"

1. Check backend is running: `curl http://localhost:5000/api/product/list`
2. Verify nginx config: `docker-compose exec frontend cat /etc/nginx/conf.d/default.conf`
3. Check CORS settings in backend: `docker-compose logs backend | grep CORS`

### Problem: Uploads directory permission denied

```bash
docker-compose exec backend chmod -R 755 /app/uploads
docker-compose restart backend
```

### Problem: "No such file or directory" for nginx.conf

Ensure `client/nginx.conf` exists and is in the correct location:
```bash
ls -la client/nginx.conf  # Should exist
```

---

## Verify All Services Summary

| Service | Port | URL | Healthcheck |
|---------|------|-----|-------------|
| Frontend (Nginx) | 80 | http://localhost | `curl http://localhost` |
| Backend (Node) | 5000 | http://localhost:5000 | `curl http://localhost:5000/api/product/list` |
| MongoDB | 27017 | localhost:27017 | `docker-compose exec mongodb mongosh` |

---

## Common Commands Reference

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mongodb

# Check status
docker-compose ps

# Restart a service
docker-compose restart backend

# Execute command in container
docker-compose exec backend npm run dev
docker-compose exec frontend bash

# View container disk usage
docker system df

# Clean up (⚠️ removes all unused images/volumes)
docker system prune -a

# Rebuild images
docker-compose build --no-cache
```

---

## Next Steps

✅ **After verification:**
1. Test creating products as a seller
2. Test browsing and adding products to cart as a user
3. Test checkout and order placement
4. Monitor logs while testing: `docker-compose logs -f`
5. Check MongoDB for data: `docker-compose exec mongodb mongosh`

✅ **For production:**
1. Use strong `JWT_SECRET`
2. Configure actual Cloudinary credentials
3. Set up environment-specific `.env` files
4. Use Docker secrets for sensitive data
5. Configure reverse proxy (Nginx/Apache) on host
6. Set up SSL/TLS certificates
7. Use health checks with load balancer

✅ **For CI/CD:**
1. Configure Jenkins with Jenkinsfile
2. Set up Docker registry credentials
3. Enable automatic builds on push
4. Deploy to staging automatically
5. Add smoke tests and monitoring
