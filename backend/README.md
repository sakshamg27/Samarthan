# Samarthan Backend API

This is the backend API for Samarthan Family Finance OS using **code-only storage** (no external database required).

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

---

**Samarthan Family Finance OS** - Empowering families with financial management tools.
