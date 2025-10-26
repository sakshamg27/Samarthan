# Samarthan - Family Finance OS

A comprehensive family finance management application built with Flutter (frontend) and Node.js (backend).

## 🚀 Railway Deployment

### Quick Deploy (Backend Only)

1. Go to [Railway](https://railway.app)
2. Click **"New Project"** → **"Deploy from GitHub repo"**
3. Select **`sakshamg27/Samarthan`**
4. Railway will detect it's a Node.js app (from root package.json)
5. Railway will automatically deploy your backend API server
6. Your API will be available at: `https://your-app.railway.app/api`

### Frontend Deployment Options

**Option A: GitHub Pages (Recommended)**
1. Go to your GitHub repo settings
2. Enable GitHub Pages
3. Set source to "GitHub Actions"
4. Push to main branch to trigger deployment

**Option B: Netlify**
1. Go to [Netlify](https://netlify.com)
2. Connect your GitHub repo
3. Set build command: `cd frontend && flutter build web --release`
4. Set publish directory: `frontend/build/web`

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