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

**Contributing**
- Feel free to open issues or pull requests. For changes to server behavior, include updated API documentation.

**License**
- MIT (add an explicit LICENSE file if required)

---
File created: `README.md` at project root. Run backend then client as described above.
