# Samarthan - Family Finance OS

A comprehensive family finance management application built with Flutter (frontend) and Node.js (backend).

## 🚀 Railway Deployment

This app needs to be deployed as **two separate services** on Railway.

### Step 1: Deploy Backend Service

1. Go to [Railway](https://railway.app)
2. Click **"New Project"** → **"Deploy from GitHub repo"**
3. Select **`sakshamg27/Samarthan`**
4. Railway will detect it's a Node.js app
5. Set **Root Directory** to: `backend`
6. Railway will automatically deploy your API server

### Step 2: Deploy Frontend Service

1. In Railway dashboard, click **"New Service"**
2. Select **"Deploy from GitHub repo"**
3. Select the same repository: **`sakshamg27/Samarthan`**
4. Set **Root Directory** to: `frontend`
5. Railway will build and deploy your Flutter web app

### Step 3: Configure Frontend API URL

1. Get your backend URL from Railway (e.g., `https://backend-production-xxxx.railway.app`)
2. Update the frontend API service to use this URL
3. Redeploy the frontend service

### Architecture

- **Frontend**: Flutter Web App (Port 3000)
- **Backend**: Node.js API Server (Port 8000)
- **Database**: In-memory storage (no external database required)

### Local Development

```bash
# Backend
cd backend && npm install && PORT=8000 node server.js

# Frontend  
cd frontend && flutter pub get && flutter run -d web-server --web-port 3000
```

### Features

- 📊 Dashboard with financial overview
- 💰 Expense tracking and management
- 🏦 Savings goals (Gullak)
- 📝 Digital ledger (Khata)
- 📈 Analytics and insights
- 🔐 Google OAuth authentication
- 📱 Responsive web interface

### Tech Stack

- **Frontend**: Flutter, Dart
- **Backend**: Node.js, Express
- **Authentication**: Google OAuth
- **Deployment**: Railway, Docker