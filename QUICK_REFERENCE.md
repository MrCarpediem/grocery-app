# Quick Reference Guide

## Running the App

### Start Everything
```bash
docker-compose up -d
```

### Stop Everything
```bash
docker-compose down
```

### Restart a Service
```bash
docker-compose restart backend
docker-compose restart frontend
docker-compose restart mongodb
```

---

## Verification & Testing

### Run Setup Verification (Recommended First Step)
```bash
./verify-setup.sh
```
Checks Docker installation, builds images, starts containers, and verifies all services.

### Run API Tests
```bash
./test-api.sh
```
Tests user registration, login, authentication, and API connectivity.

### Manual API Testing with curl

**Get all products:**
```bash
curl http://localhost:5000/api/product/list
```

**Register a user:**
```bash
curl -X POST http://localhost:5000/api/user/register \
  -H "Content-Type: application/json" \
  -d '{
    "name":"John Doe",
    "email":"john@example.com",
    "password":"password123"
  }'
```

**Login a user:**
```bash
curl -X POST http://localhost:5000/api/user/login \
  -H "Content-Type: application/json" \
  -c cookies.txt \
  -d '{
    "email":"john@example.com",
    "password":"password123"
  }'
```

**Check authentication (with cookie):**
```bash
curl -b cookies.txt http://localhost:5000/api/user/is-auth
```

---

## Logging & Debugging

### View All Logs
```bash
docker-compose logs
```

### Follow Backend Logs (Real-time)
```bash
docker-compose logs -f backend
```

### Follow Frontend Logs
```bash
docker-compose logs -f frontend
```

### Follow MongoDB Logs
```bash
docker-compose logs -f mongodb
```

### View last 50 lines of backend logs
```bash
docker-compose logs backend --tail=50
```

### View logs since last 10 minutes
```bash
docker-compose logs --since 10m backend
```

---

## Database Management

### Connect to MongoDB Shell
```bash
docker-compose exec mongodb mongosh \
  --username admin \
  --password password \
  --authenticationDatabase admin
```

### Once in MongoDB Shell

```javascript
// Switch to grocery-app database
use grocery-app

// List collections
show collections

// Count users
db.users.count()

// View all users
db.users.find()

// View user details
db.users.findOne({ email: "test@example.com" })

// View products
db.products.find()

// View orders
db.orders.find()

// Delete a user
db.users.deleteOne({ email: "test@example.com" })

// Clear all users (careful!)
db.users.deleteMany({})

// Exit MongoDB shell
exit
```

---

## Container Management

### Check Container Status
```bash
docker-compose ps
```

### Execute Command in Container
```bash
docker-compose exec backend bash
docker-compose exec frontend bash
docker-compose exec mongodb bash
```

### View Container Disk Usage
```bash
docker system df
```

### Remove All Unused Images (Warning: destructive)
```bash
docker system prune -a
```

### Rebuild Images from Scratch
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### View Image Layers
```bash
docker inspect grocery-backend:latest
```

---

## Troubleshooting

### Backend won't start / "Cannot find module"

**Solution:** Rebuild without cache
```bash
docker-compose down
docker-compose build --no-cache backend
docker-compose up -d
```

**Check logs:**
```bash
docker-compose logs backend
```

### Port already in use (80 or 5000)

**Check what's using the port:**
```bash
lsof -i :80
lsof -i :5000
lsof -i :27017
```

**Or modify docker-compose.yml ports and rebuild:**
```yaml
frontend:
  ports:
    - "8080:80"  # Change 80 to 8080

backend:
  ports:
    - "5001:5000"  # Change 5000 to 5001
```

### MongoDB connection error

**Restart MongoDB:**
```bash
docker-compose restart mongodb
sleep 5
docker-compose restart backend
```

**Check MongoDB health:**
```bash
docker-compose exec mongodb mongosh --version
```

### Frontend shows "Cannot connect to API"

**1. Check backend is running:**
```bash
curl http://localhost:5000/api/product/list
```

**2. Check nginx config:**
```bash
docker-compose exec frontend cat /etc/nginx/conf.d/default.conf
```

**3. Check backend logs for errors:**
```bash
docker-compose logs backend | tail -20
```

**4. Test proxy:**
```bash
curl -H "Host: localhost" http://localhost/api/product/list
```

### Uploads folder permission denied

```bash
docker-compose exec backend chmod -R 755 /app/uploads
docker-compose restart backend
```

### Changes not reflected after code edit

Rebuild the affected service:
```bash
docker-compose build --no-cache backend
docker-compose up -d
```

Or for frontend:
```bash
docker-compose build --no-cache frontend
docker-compose up -d
```

### All containers suddenly stopped

**Check why:**
```bash
docker-compose logs
```

**Restart:**
```bash
docker-compose restart
```

---

## Performance & Optimization

### Check Docker Disk Usage
```bash
docker system df
```

### Prune Unused Volumes (Warning: removes unused volumes)
```bash
docker volume prune
```

### View Container Resource Usage
```bash
docker stats
```

### Limit Container Resource Usage

Edit `docker-compose.yml`:
```yaml
backend:
  deploy:
    resources:
      limits:
        cpus: '1'
        memory: 512M
      reservations:
        cpus: '0.5'
        memory: 256M
```

---

## Development Workflow

### 1. Make code changes
Edit files in `backend/` or `client/`

### 2. Rebuild affected service
```bash
docker-compose build backend
# or
docker-compose build frontend
```

### 3. Restart service
```bash
docker-compose up -d
```

### 4. View logs
```bash
docker-compose logs -f backend
```

### 5. Test changes
```bash
./test-api.sh
curl http://localhost
```

---

## Useful Docker Compose Commands

| Command | Purpose |
|---------|---------|
| `docker-compose up -d` | Start all services in background |
| `docker-compose down` | Stop and remove containers |
| `docker-compose logs -f` | Follow logs of all services |
| `docker-compose ps` | Show running containers |
| `docker-compose restart` | Restart all services |
| `docker-compose build` | Build all images |
| `docker-compose exec mongodb bash` | Shell into MongoDB container |
| `docker-compose pull` | Pull latest images |
| `docker-compose top backend` | Show processes in backend container |

---

## Environment Variables

Default values in `docker-compose.yml`:

```env
MONGO_URI=mongodb://admin:password@mongodb:27017/grocery-app?authSource=admin
JWT_SECRET=your_jwt_secret_key
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
SELLER_EMAIL=seller@example.com
PORT=5000
STRIPE_SECRET_KEY=sk_test_...
VITE_API_URL=http://localhost:5000
```

Customize in `.env` file.

---

## Next Steps

✅ **After running `./verify-setup.sh`:**
1. Open http://localhost in browser
2. Register a test user
3. Browse products
4. Add to cart
5. Try checkout

✅ **For production:**
1. Set strong `JWT_SECRET`
2. Configure Cloudinary credentials
3. Set up proper MongoDB with authentication
4. Use environment-specific `.env` files
5. Configure SSL/TLS
6. Set up monitoring and logging

---

**For complete setup guide, see: [DOCKER_SETUP.md](./DOCKER_SETUP.md)**
