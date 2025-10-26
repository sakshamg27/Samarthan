# Samarthan - Family Finance OS

A comprehensive family finance management application built with Flutter (frontend) and Node.js (backend).

## 🚀 Railway Deployment

This app is configured for deployment on Railway.

### Quick Deploy

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/deploy)

### Manual Deploy

1. Go to [Railway](https://railway.app)
2. Connect your GitHub account
3. Select this repository
4. Railway will automatically detect and deploy both services

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