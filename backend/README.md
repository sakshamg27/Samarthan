# Samarthan Backend API

## 🚀 Production-Ready Node.js Backend

This is the backend API for Samarthan Family Finance OS using **code-only storage** (no external database required).

## 📦 What's Included

- ✅ **server.js** - Main production server
- ✅ **package.json** - Dependencies and scripts
- ✅ **.env.example** - Environment variables template

## 🚀 Quick Start

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Environment
```bash
cp .env.example .env
# Edit .env with your actual values
```

### 3. Start Server
```bash
npm start
```

## 🔧 Environment Variables

```bash
NODE_ENV=production
PORT=3000
JWT_SECRET=your-super-secret-jwt-key
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
FRONTEND_URL=https://your-frontend-url.com
```

## 📡 API Endpoints

- `POST /api/auth/google` - Google OAuth login
- `GET /api/user` - Get current user
- `GET /api/expenses` - Get user expenses
- `POST /api/expenses` - Create expense
- `PUT /api/expenses/:id/paid` - Mark as paid
- `DELETE /api/expenses/:id` - Delete expense
- `GET /api/savings` - Get user savings
- `POST /api/savings` - Create savings
- `DELETE /api/savings/:id` - Delete savings
- `GET /api/samarthan-score` - Get credit score
- `GET /api/dashboard` - Get dashboard data
- `GET /api/analytics` - Get analytics data
- `GET /api/notifications` - Get notifications

## 💾 Storage

**Code-Only Storage**: All data stored in server memory arrays
- No external database required
- Perfect for demos and prototypes
- Data persists during server uptime
- Resets when server restarts

## 🚀 Deployment

### Render.com (Recommended)
1. Connect GitHub repository
2. Set build command: `npm install`
3. Set start command: `npm start`
4. Add environment variables
5. Deploy!

**Total Monthly Cost: $0** (Free tier)

## 🔒 Security Features

- ✅ HTTPS encryption
- ✅ JWT authentication
- ✅ Input validation
- ✅ CORS protection
- ✅ Error handling

---

**Samarthan Family Finance OS** - Empowering families with financial management tools.
