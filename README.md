# Samarthan - Family Finance OS

A comprehensive family finance management application built with Flutter (frontend) and Node.js (backend).

## 🚀 Railway Deployment

### Quick Deploy

1. Go to [Railway](https://railway.app)
2. Click **"New Project"** → **"Deploy from GitHub repo"**
3. Select **`sakshamg27/Samarthan`**
4. Railway will automatically detect the Dockerfile and deploy your backend API
5. Your API will be available at: `https://your-app.railway.app/api`

### What Gets Deployed

- ✅ **Backend API Server** (Node.js/Express)
- ✅ **All API endpoints** (`/api/*`)
- ✅ **Google OAuth authentication**
- ✅ **In-memory data storage**
- ✅ **Health check endpoint** (`/api/health`)

### Frontend Development

For local frontend development:
```bash
cd frontend
flutter pub get
flutter run -d web-server --web-port 3000
```

**Note:** The frontend is designed to work with the deployed backend API. Update the API URL in `frontend/lib/services/api_service.dart` to point to your Railway deployment URL.

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