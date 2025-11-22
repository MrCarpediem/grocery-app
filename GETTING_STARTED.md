# Getting Started - Visual Guide

## 📋 Prerequisites Checklist

Before you start, make sure you have:

```
✅ Docker installed         → https://docs.docker.com/get-docker/
✅ Docker Compose installed → https://docs.docker.com/compose/install/
✅ Git installed            → https://git-scm.com/
✅ This repository cloned   → cd ~/grocery-app
```

Verify:
```bash
docker --version
docker-compose --version
```

---

## 🚀 5-Minute Quick Start

### Step 1: Prepare Environment
```bash
cd ~/grocery-app
cp .env.example .env
```
(You can keep default values or customize as needed)

### Step 2: Start Services
```bash
docker-compose up -d
```
This starts:
- MongoDB (database)
- Backend (API server)
- Frontend (web app)

### Step 3: Verify Installation
```bash
./verify-setup.sh
```
This checks:
- Docker is running
- Images are built
- Containers are healthy
- Services are responding

### Step 4: Test APIs (Optional)
```bash
./test-api.sh
```
This tests:
- User registration
- User login
- Authentication
- API connectivity

### Step 5: Open in Browser
```
http://localhost
```

**Done!** ✨

---

## 📊 Service Status

After starting, check with:
```bash
docker-compose ps
```

You should see:
```
NAME          STATUS           SERVICE
grocery-backend    Up (healthy)     backend
grocery-frontend   Up               frontend  
grocery-mongodb    Up (healthy)     mongodb
```

---

## 🌐 Access Your App

| Service | URL | Port |
|---------|-----|------|
| Web App | http://localhost | 80 |
| Backend API | http://localhost:5000 | 5000 |
| MongoDB | localhost:27017 | 27017 |

### Test Backend is Running
```bash
curl http://localhost:5000/api/product/list
```
Should return: `[]` (empty products list)

### Test Frontend is Running
```bash
curl http://localhost
```
Should return HTML content

---

## 📝 Common Tasks

### View Logs
```bash
# All services
docker-compose logs -f

# Just backend
docker-compose logs -f backend

# Just frontend  
docker-compose logs -f frontend

# Just MongoDB
docker-compose logs -f mongodb
```

### Stop Services
```bash
docker-compose down
```

### Restart Services
```bash
docker-compose restart
```

### Rebuild After Code Changes
```bash
docker-compose build backend
docker-compose up -d
```

### Connect to Database
```bash
docker-compose exec mongodb mongosh \
  --username admin \
  --password password \
  --authenticationDatabase admin
```

---

## 🧪 Testing Flow

### 1. Register a User
Open http://localhost and click "Register"
- Email: `test@example.com`
- Password: `password123`

### 2. Browse Products
You should see a product grid (empty initially)

### 3. Add Product as Seller
Using the seller login (if you have credentials)

### 4. Add to Cart
Click product → Add to cart

### 5. Checkout
Go to cart → Proceed to checkout

### 6. Check Database
```bash
docker-compose exec mongodb mongosh -c \
  "use grocery-app; db.users.find()"
```

---

## 🔧 Troubleshooting Quick Links

| Issue | Solution |
|-------|----------|
| "Port already in use" | Edit docker-compose.yml, change ports |
| "Cannot connect to API" | Run `docker-compose logs backend` |
| "Database error" | Run `docker-compose restart mongodb` |
| "Services won't start" | Run `docker-compose build --no-cache` |
| "Changes not showing" | Rebuild: `docker-compose build backend` |

See **QUICK_REFERENCE.md** for detailed troubleshooting.

---

## 📚 Documentation Map

```
├── README.md ........................ Main project overview
├── SETUP_COMPLETE.md ............... What was added (this checklist)
├── DOCKER_SETUP.md ................. Complete step-by-step guide
├── QUICK_REFERENCE.md .............. Commands & troubleshooting
├── GETTING_STARTED.md .............. Visual guide (YOU ARE HERE)
│
├── docker-compose.yml .............. Service orchestration
├── Jenkinsfile ..................... CI/CD pipeline
│
├── backend/
│   ├── Dockerfile .................. Backend container
│   ├── .dockerignore ............... Build exclusions
│   └── ...
│
└── client/
    ├── Dockerfile .................. Frontend container
    ├── nginx.conf .................. Web server config
    ├── .dockerignore ............... Build exclusions
    └── ...
```

---

## 📋 First Run Checklist

- [ ] Docker and Docker Compose installed
- [ ] Repository cloned: `cd ~/grocery-app`
- [ ] Environment copied: `cp .env.example .env`
- [ ] Services started: `docker-compose up -d`
- [ ] Verification passed: `./verify-setup.sh`
- [ ] API responds: `curl http://localhost:5000/api/product/list`
- [ ] Frontend loads: http://localhost
- [ ] Registration works: Created test user
- [ ] Database has data: `docker-compose exec mongodb mongosh`

---

## 🎯 Key Files

### Most Important
- **docker-compose.yml** - How services talk to each other
- **.env** - Your configuration
- **README.md** - Quick start reference

### Documentation
- **DOCKER_SETUP.md** - Detailed verification guide
- **QUICK_REFERENCE.md** - Commands and troubleshooting
- **SETUP_COMPLETE.md** - Summary of changes

### Automation
- **verify-setup.sh** - One-command verification
- **test-api.sh** - One-command API testing
- **Jenkinsfile** - CI/CD pipeline

---

## 🚦 Status Indicators

### ✅ Everything Working
```bash
$ docker-compose ps
NAME             STATUS              SERVICE
grocery-backend  Up 2 minutes (healthy)
grocery-frontend Up 2 minutes
grocery-mongodb  Up 2 minutes (healthy)
```

### ⚠️ MongoDB Starting
```bash
docker-compose logs mongodb | grep "waiting"
```
Wait 30 seconds for full health.

### ❌ Service Down
```bash
docker-compose restart <service>
docker-compose logs <service>
```

---

## 📞 Need Help?

### Quick Help
```bash
cat QUICK_REFERENCE.md
```

### Step-by-Step Help
```bash
cat DOCKER_SETUP.md
```

### Setup Summary
```bash
cat SETUP_COMPLETE.md
```

### View What's Running
```bash
docker-compose ps
docker-compose logs
```

---

## 🎉 You're Ready!

Everything is set up. Now:

1. **Verify:** `./verify-setup.sh`
2. **Test:** `./test-api.sh`
3. **Browse:** http://localhost
4. **Explore:** Register, login, add products
5. **Monitor:** `docker-compose logs -f`

For detailed steps, see **DOCKER_SETUP.md**.

---

## Advanced Usage

### Custom Ports
Edit `docker-compose.yml` ports section:
```yaml
frontend:
  ports:
    - "8080:80"      # Access at http://localhost:8080
backend:
  ports:
    - "5001:5000"    # Access at http://localhost:5001
```

### Environment Variables
Edit `.env` file:
```env
MONGO_PASSWORD=mypassword
JWT_SECRET=mysecretkey
SELLER_EMAIL=seller@mysite.com
```

### CI/CD Pipeline
See **Jenkinsfile** for automated deployment setup.

---

**Last Updated:** November 21, 2025  
**Status:** ✅ Ready to run  
**Next:** Run `./verify-setup.sh`
