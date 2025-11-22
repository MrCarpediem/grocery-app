# 🎯 How to Run & Verify - Complete Guide

## ⚡ Express Start (30 seconds)

```bash
cd ~/grocery-app
cp .env.example .env
docker-compose up -d
./verify-setup.sh
```

Then open: **http://localhost**

---

## 📋 Step-by-Step Verification

### Phase 1: Pre-Flight Check

#### 1.1 Check Docker Installation
```bash
docker --version
docker-compose --version
```

**Expected Output:**
```
Docker version 24.0.0 (or higher)
Docker Compose version 2.0.0 (or higher)
```

#### 1.2 Check Docker Daemon
```bash
docker ps
```

**Expected Output:**
```
CONTAINER ID   IMAGE      COMMAND        CREATED        STATUS
(empty list or existing containers)
```

If error: **Start Docker Desktop/daemon**

---

### Phase 2: Project Setup

#### 2.1 Clone Repository
```bash
git clone https://github.com/MrCarpediem/grocery-app.git
cd grocery-app
```

#### 2.2 Copy Environment File
```bash
cp .env.example .env
```

**Check file created:**
```bash
ls -la .env
```

**Expected:** File exists with default values

#### 2.3 Review Environment Variables
```bash
cat .env
```

**Key variables to know:**
- `MONGO_USER=admin` - Database user
- `MONGO_PASSWORD=password` - Database password
- `JWT_SECRET=your_jwt_secret_key` - Auth token secret
- `SELLER_EMAIL=seller@example.com` - Seller account

---

### Phase 3: Start Services

#### 3.1 Build and Start All Containers
```bash
docker-compose up -d
```

**Expected Output:**
```
[+] Running 4/4
 ✔ Network grocery-network Created
 ✔ Volume "mongo_data" Created
 ✔ Container grocery-mongodb Created
 ✔ Container grocery-backend Created
 ✔ Container grocery-frontend Created
```

#### 3.2 Check Container Status
```bash
docker-compose ps
```

**Expected Output:**
```
NAME                COMMAND                  SERVICE      STATUS
grocery-backend     "dumb-init -- node..."   backend      Up 15 seconds (healthy)
grocery-frontend    "nginx -g daemon..."     frontend     Up 13 seconds
grocery-mongodb     "mongod --..."           mongodb      Up 17 seconds (healthy)
```

**Key Points:**
- All containers should show `Up` status
- Backend and MongoDB should show `(healthy)`
- If not healthy, wait 30 seconds and check again: `docker-compose ps`

---

### Phase 4: Automated Verification

#### 4.1 Run Verification Script
```bash
./verify-setup.sh
```

**Script Checks:**
1. Docker installation ✓
2. Docker Compose installation ✓
3. Docker daemon running ✓
4. .env file exists ✓
5. docker-compose.yml exists ✓
6. Dockerfiles exist ✓
7. Images built ✓
8. Containers started ✓
9. Services initializing ✓
10. Health checks passed ✓

**Expected Output:**
```
================================================
  Grocery App - Docker Setup Verification
================================================

[1/10] Checking Docker installation...
✓ Docker installed: Docker version 24.x.x

[2/10] Checking Docker Compose installation...
✓ Docker Compose installed: Docker Compose version 2.x.x

... (more checks) ...

✓ Setup Complete!
================================================

Access your app:
  Frontend:  http://localhost
  Backend:   http://localhost:5000
  API Docs:  http://localhost:5000/api/product/list
```

---

### Phase 5: API Testing

#### 5.1 Manual Backend Test
```bash
curl http://localhost:5000/api/product/list
```

**Expected Response:**
```json
[]
```
(Empty array - no products yet)

#### 5.2 Automated API Testing
```bash
./test-api.sh
```

**Script Tests:**
1. Backend connectivity
2. Fetch products
3. User registration
4. User login
5. Authentication check
6. Container status
7. MongoDB connectivity

**Expected Output:**
```
========================================
  Grocery App - API Test Suite
========================================

[Test 1] Backend connectivity...
✓ Backend is reachable

[Test 2] Fetching products list...
✓ Response: []

[Test 3] User registration...
✓ User registered successfully
  Email: testuser1234567890@example.com

[Test 4] User login...
✓ User logged in successfully

[Test 5] Checking authentication...
✓ Authentication verified

[Test 6] Frontend connectivity...
✓ Frontend is accessible

[Test 7] Container status...
NAME             STATUS              SERVICE
grocery-backend  Up 1 minute (healthy)
...

[Test 8] MongoDB connectivity...
✓ MongoDB is accessible
  Users in database: 1

All tests completed!
```

---

### Phase 6: Frontend Testing

#### 6.1 Open Web App
```bash
# Open in browser or use curl
curl http://localhost | head -20
```

**Expected:** HTML content (not connection error)

**In Browser:** http://localhost

You should see:
- ✅ Navigation bar
- ✅ Logo
- ✅ Search bar
- ✅ Login/Register button
- ✅ Product grid (empty initially)
- ✅ Categories
- ✅ Footer

#### 6.2 User Registration Test
1. Click **Register** button
2. Fill in form:
   - Email: `test@example.com`
   - Password: `password123`
   - Confirm: `password123`
3. Click **Register**
4. Expected: Redirect to home or "Registration successful" message

#### 6.3 User Login Test
1. Click **Login** button
2. Enter credentials:
   - Email: `test@example.com`
   - Password: `password123`
3. Click **Login**
4. Expected: "Welcome" message or redirect to home

#### 6.4 Open DevTools to Check
1. Press **F12** (or Cmd+Option+I on Mac)
2. Go to **Network** tab
3. Register a user
4. You should see:
   - `POST /api/user/register` - Status **200** ✅
   - `POST /api/user/login` - Status **200** ✅

---

### Phase 7: Database Verification

#### 7.1 Connect to MongoDB
```bash
docker-compose exec mongodb mongosh \
  --username admin \
  --password password \
  --authenticationDatabase admin
```

#### 7.2 Check Database Contents
Inside MongoDB shell:

```javascript
// Switch to database
use grocery-app

// Show all collections
show collections

// Count users (if you registered earlier)
db.users.count()

// View all users
db.users.find()

// View specific user
db.users.findOne({ email: "test@example.com" })

// Check products
db.products.find()

// Check orders
db.orders.find()

// Exit
exit
```

**Expected Output:**
```
grocery-app> db.users.count()
1

grocery-app> db.users.findOne()
{
  _id: ObjectId(...),
  name: 'Test User',
  email: 'test@example.com',
  ...
}
```

---

### Phase 8: Logs Review

#### 8.1 View Backend Logs
```bash
docker-compose logs backend --tail=20
```

**Expected:**
```
backend  | Server is running on port 5000
backend  | MongoDB connected
```

#### 8.2 View MongoDB Logs
```bash
docker-compose logs mongodb --tail=20
```

**Expected:**
```
mongodb  | waiting for connections on port 27017
mongodb  | connection accepted
```

#### 8.3 View Frontend Logs
```bash
docker-compose logs frontend --tail=20
```

**Expected:**
```
frontend | 2024/11/21 10:00:00 [notice] ... listening on port 80
```

#### 8.4 Follow Real-Time Logs
```bash
docker-compose logs -f backend
```
(Press Ctrl+C to stop)

---

### Phase 9: Full Integration Test

#### 9.1 Complete User Journey

1. **Register User**
```bash
curl -X POST http://localhost:5000/api/user/register \
  -H "Content-Type: application/json" \
  -d '{
    "name":"John Doe",
    "email":"john@test.com",
    "password":"pass123"
  }' \
  -c cookies.txt
```

2. **Login**
```bash
curl -X POST http://localhost:5000/api/user/login \
  -H "Content-Type: application/json" \
  -b cookies.txt -c cookies.txt \
  -d '{
    "email":"john@test.com",
    "password":"pass123"
  }'
```

3. **Check Auth**
```bash
curl -b cookies.txt http://localhost:5000/api/user/is-auth
```

4. **Add Address**
```bash
curl -X POST http://localhost:5000/api/address/add \
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
  }'
```

5. **Check in Database**
```bash
docker-compose exec mongodb mongosh -c \
  "use grocery-app; db.addresses.find()"
```

**Expected:** Address saved in MongoDB ✅

---

### Phase 10: Health Check Summary

Run this final check:

```bash
echo "=== Docker Status ==="
docker ps --format "table {{.Names}}\t{{.Status}}"

echo -e "\n=== API Health ==="
curl -s http://localhost:5000/api/product/list && echo " ✓ Backend OK"
curl -s http://localhost && echo " ✓ Frontend OK" || echo " ✗ Frontend failed"

echo -e "\n=== Database Health ==="
docker-compose exec -T mongodb mongosh --version && echo "✓ MongoDB OK" || echo "✗ MongoDB failed"

echo -e "\n=== Services Running ==="
docker-compose ps
```

**Expected Output:**
```
=== Docker Status ===
grocery-backend     Up 5 minutes (healthy)
grocery-frontend    Up 5 minutes
grocery-mongodb     Up 5 minutes (healthy)

=== API Health ===
[] ✓ Backend OK
✓ Frontend OK

=== Database Health ===
... ✓ MongoDB OK

=== Services Running ===
NAME             STATUS              SERVICE
grocery-backend  Up 5 minutes (healthy)
grocery-frontend Up 5 minutes
grocery-mongodb  Up 5 minutes (healthy)
```

---

## ✅ Verification Checklist

- [ ] Docker & Docker Compose installed
- [ ] Repository cloned
- [ ] `.env` file copied and reviewed
- [ ] `docker-compose up -d` completed
- [ ] `docker-compose ps` shows all containers UP
- [ ] MongoDB and backend show (healthy)
- [ ] `./verify-setup.sh` passed
- [ ] `./test-api.sh` passed
- [ ] Frontend loads at http://localhost
- [ ] User registration works
- [ ] User login works
- [ ] Database has user records
- [ ] Backend logs show no errors
- [ ] All API endpoints respond

**All ✅ checked = System is working correctly!**

---

## 🚨 If Something's Wrong

### Backend not responding
```bash
docker-compose logs backend
docker-compose restart backend
```

### Can't access frontend
```bash
docker-compose logs frontend
curl -v http://localhost
```

### Database connection error
```bash
docker-compose restart mongodb
sleep 10
docker-compose logs mongodb
```

### Containers won't start
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Port already in use
Edit `docker-compose.yml` and change ports:
```yaml
frontend:
  ports:
    - "8080:80"  # Use 8080 instead of 80
```

See **QUICK_REFERENCE.md** for detailed troubleshooting.

---

## 📚 Documentation Files

| File | Purpose | When to Read |
|------|---------|--------------|
| **README.md** | Project overview | First - quick start |
| **GETTING_STARTED.md** | Visual guide | New to Docker |
| **DOCKER_SETUP.md** | Detailed setup | Complete 8-step guide |
| **QUICK_REFERENCE.md** | Commands & fixes | Troubleshooting |
| **SETUP_COMPLETE.md** | What was added | Understanding changes |

---

## 🎉 Success Indicators

✅ **You're Good If:**
- All 3 containers show `Up` status
- MongoDB and backend show `(healthy)`
- `./verify-setup.sh` completes without errors
- http://localhost loads in browser
- API returns JSON (not connection error)
- Can register and login user
- User data appears in MongoDB

❌ **Something's Wrong If:**
- Container shows `Exited`
- Ports don't respond
- Logs show errors
- API returns connection refused
- Frontend shows blank page

**Fix:** Run `docker-compose logs` and read error messages.

---

## 🚀 Ready to Deploy?

After verification, you can:

1. **Push to GitHub** - Triggers Jenkins CI/CD
2. **Deploy to Production** - Update environment variables
3. **Scale Services** - Add more containers
4. **Monitor** - Check logs and metrics

See **Jenkinsfile** for CI/CD setup.

---

## 📞 Quick Help

**View all logs:**
```bash
docker-compose logs
```

**Stop everything:**
```bash
docker-compose down
```

**Check what's running:**
```bash
docker-compose ps
```

**Restart everything:**
```bash
docker-compose restart
```

**Connect to database:**
```bash
docker-compose exec mongodb mongosh
```

---

**Status:** ✅ Ready to verify  
**Next Step:** Run `./verify-setup.sh`  
**Time to Complete:** 5-10 minutes

Good luck! 🚀
