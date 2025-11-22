**Grocery App**

A simple full-stack grocery store application with a React + Vite frontend and an Express + MongoDB backend. The app supports user authentication, seller authentication, product management (with image upload via Cloudinary), cart & address management, and order placement (COD).

**Tech Stack**
- **Frontend**: React, Vite, Tailwind CSS
- **Backend**: Node.js, Express, MongoDB (Mongoose)
- **Auth**: JWT stored in cookies
- **Images**: Local `uploads/` (served at `/images`) and Cloudinary for remote storage
- **Other**: Stripe (optional), Multer for file uploads

**Repository Structure (important parts)**
- **`/backend`**: Express API server and routes
- **`/client`**: React frontend (Vite)
- **`/uploads`**: Local static folder for uploaded images (served at `/images`)

**Quick Start**

### Docker & Docker Compose (Recommended) ⚡
Prerequisites: Docker & Docker Compose installed.

**Fastest way to get running:**

```bash
# 1. Copy environment template
cp .env.example .env

# 2. Start all services
docker-compose up -d

# 3. Verify setup and run tests (optional but recommended)
./verify-setup.sh

# 4. Test API endpoints
./test-api.sh
```

**Access your app:**
- **Frontend:** http://localhost
- **Backend API:** http://localhost:5000/api/product/list

**Common commands:**
```bash
docker-compose logs -f backend      # View backend logs
docker-compose ps                   # Check service status
docker-compose down                 # Stop all services
```

**For detailed verification guide, see:** [DOCKER_SETUP.md](./DOCKER_SETUP.md)

### Local Development (without Docker)
Prerequisites: Node 18+, npm, MongoDB (or MongoDB Atlas), Cloudinary account (if using remote uploads).

1. Start the backend

```bash
cd backend
npm install
# create a .env with the values listed below
npm run dev
```

2. Start the frontend

```bash
cd client
npm install
npm run dev
```

Open the frontend at the address shown by Vite (usually `http://localhost:5173`). The backend runs on `PORT` (default `5000`).

**Environment Variables**
Create a `.env` file inside `backend/` containing at minimum:

- `MONGO_URI` : MongoDB connection string (e.g. `mongodb://localhost:27017/grocery-app` or Atlas URI)
- `JWT_SECRET` : Secret used to sign JWT tokens
- `CLOUDINARY_CLOUD_NAME` : (optional) Cloudinary cloud name
- `CLOUDINARY_API_KEY` : (optional) Cloudinary API key
- `CLOUDINARY_API_SECRET` : (optional) Cloudinary API secret
- `SELLER_EMAIL` : Email used to validate seller token in `authSeller` middleware
- `PORT` : (optional) port for backend server (default `5000`)
- `STRIPE_SECRET_KEY` : (optional) Stripe secret key if payments are integrated

Example `backend/.env`:

```env
MONGO_URI=mongodb://localhost:27017/grocery-app
JWT_SECRET=your_jwt_secret_here
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
SELLER_EMAIL=seller@example.com
PORT=5000
STRIPE_SECRET_KEY=sk_test_...
```

**Backend scripts** (`backend/package.json`)
- `npm run dev` : Start the server with `nodemon index.js` (development)

**Frontend scripts** (`client/package.json`)
- `npm run dev` : Start Vite dev server
- `npm run build` : Build production assets
- `npm run preview` : Preview production build

**API Endpoints (summary)**
Base path: `/api`

- **User** (`/api/user`)
  - `POST /register` : Register a user
  - `POST /login` : Login user (sets cookie token)
  - `GET /is-auth` : Check user auth (protected)
  - `GET /logout` : Logout user

- **Seller** (`/api/seller`)
  - `POST /login` : Seller login (sets sellerToken cookie)
  - `GET /is-auth` : Check seller auth (protected)
  - `GET /logout` : Logout seller

- **Product** (`/api/product`)
  - `POST /add-product` : Add product (seller auth + multipart images up to 4)
  - `GET /list` : List products
  - `GET /id` : Get product by id (query param)
  - `POST /stock` : Change stock (seller auth)

- **Cart** (`/api/cart`)
  - `POST /update` : Update user cart (auth required)

- **Address** (`/api/address`)
  - `POST /add` : Add address (auth required)
  - `GET /get` : Get addresses (auth required)

- **Order** (`/api/order`)
  - `POST /cod` : Place order (Cash on Delivery) (auth required)
  - `GET /user` : Get orders for logged-in user (auth required)
  - `GET /seller` : Get all orders for seller (seller auth)

Other notable routes:
- Static images: `GET /images/<filename>` serves files from the `uploads/` folder.

**CORS & Cookies**
- The backend in `index.js` allows origins for local development (examples include `http://localhost:5173`, `http://localhost:5174`, `http://127.0.0.1:5173`, `http://127.0.0.1:5174`).
- Authentication uses JWT tokens stored in cookies (`token` for users and `sellerToken` for sellers).

**Testing the app locally**
- Register/login a user from the frontend UI, add products as the seller, and test cart/checkout flows.

**Troubleshooting**
- If uploads do not appear, confirm files are being saved to `backend/uploads` and that the server has permission to write to that directory.
- If auth fails, confirm `JWT_SECRET` matches the value used to sign tokens and that cookies are sent with requests (frontend should use `credentials: 'include'` or similar).

**Docker Troubleshooting**
- If containers fail to start, check logs: `docker-compose logs <service-name>`
- Ensure port 80, 5000, and 27017 are not in use or change them in `docker-compose.yml`
- For permission issues with `uploads/` volume, run: `docker-compose exec backend chmod -R 755 /app/uploads`

**CI/CD with Jenkins**

A `Jenkinsfile` is included for automated builds and deployments. 

**Setup**
1. Install Jenkins and Docker plugins (`Docker`, `Docker Pipeline`)
2. Create a new Pipeline job in Jenkins pointing to this repository
3. Configure Jenkins credentials:
   - `docker-registry-creds`: Docker Hub or private registry credentials
4. Set environment variables in Jenkins or add to `.env`

**Pipeline Stages**
- **Checkout**: Clone the repository
- **Build Backend**: Build backend Docker image
- **Build Frontend**: Build frontend Docker image
- **Test Backend**: Install dependencies and validate backend
- **Test Frontend**: Run linting and validate frontend
- **SonarQube Analysis**: Optional static code analysis (requires SonarQube setup)
- **Push to Registry**: Push images to Docker registry (main branch only)
- **Deploy to Staging**: Deploy using docker-compose (main branch only)
- **Smoke Tests**: Verify services are running and responding

**Jenkins Configuration Tips**
- Add webhook to GitHub for automatic builds on push
- Configure credentials for Docker registry and MongoDB
- Set build triggers for branches and pull requests
- Add email/Slack notifications for build status

**Testing the CI/CD**
Push to `main` branch to trigger the pipeline:
```bash
git push origin main
```
Monitor the Jenkins dashboard for build progress.

**Contributing**
- Feel free to open issues or pull requests. For changes to server behavior, include updated API documentation.

**License**
- MIT (add an explicit LICENSE file if required)

---
File created: `README.md` at project root. Run backend then client as described above.
