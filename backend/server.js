const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const moment = require('moment');
const { OAuth2Client } = require('google-auth-library');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Google OAuth client
const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// Production-ready middleware
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? [process.env.FRONTEND_URL || 'https://your-domain.com'] 
    : true,
  credentials: true
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Security headers
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  next();
});

// In-memory storage (code-only, no external database)
let users = [];
let expenses = [];
let savings = [];
let scores = [];

// Helper function to generate ID
const generateId = () => Math.random().toString(36).substr(2, 9);

// Google OAuth verification
const verifyGoogleToken = async (token) => {
  try {
    // Handle demo mode
    if (token === 'demo_user_123') {
      return {
        googleId: 'demo_user_123',
        email: 'demo@samarthan.com',
        name: 'Demo User',
        picture: 'https://via.placeholder.com/150',
        emailVerified: true
      };
    }
    
    // Verify with Google (for production)
    const ticket = await googleClient.verifyIdToken({
      idToken: token,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    const payload = ticket.getPayload();
    return {
      googleId: payload.sub,
      email: payload.email,
      name: payload.name,
      picture: payload.picture,
      emailVerified: payload.email_verified
    };
  } catch (error) {
    console.error('Google token verification error:', error);
    throw new Error('Invalid Google token');
  }
};

// Input validation helpers
const validateEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

const validateAmount = (amount) => {
  return typeof amount === 'number' && amount > 0;
};

const validateRequired = (value) => {
  return value && value.toString().trim().length > 0;
};

// Authentication middleware
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({ message: 'Access token required' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
    req.user = decoded;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Token expired', code: 'TOKEN_EXPIRED' });
    } else if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ message: 'Invalid token', code: 'INVALID_TOKEN' });
    } else {
      return res.status(500).json({ message: 'Authentication error', code: 'AUTH_ERROR' });
    }
  }
};

// Samarthan Score calculation
const calculateSamarthanScore = (userId) => {
  try {
    const userExpenses = expenses.filter(expense => expense.userId === userId);
    const userSavings = savings.filter(saving => saving.userId === userId);

    // If no data, return 0
    if (userExpenses.length === 0 && userSavings.length === 0) {
      return {
        score: 0,
        scoreFactors: {
          billPaymentConsistency: 0,
          savingsDiscipline: 0,
          cashFlowManagement: 0,
          overdueBills: 0
        }
      };
    }

    // Bill Payment Consistency (30 points max)
    const billsWithDueDate = userExpenses.filter(expense => expense.dueDate);
    const paidOnTime = billsWithDueDate.filter(expense => 
      expense.isPaid && expense.paidDate && 
      moment(expense.paidDate).isSameOrBefore(expense.dueDate)
    );
    const billsWithoutDueDate = userExpenses.filter(expense => !expense.dueDate && expense.isPaid);
    const billPaymentConsistency = billsWithDueDate.length > 0 
      ? Math.round((paidOnTime.length + billsWithoutDueDate.length) / userExpenses.length * 30)
      : billsWithoutDueDate.length > 0 ? 30 : 0;

    // Savings Discipline (25 points max)
    const totalSavings = userSavings.reduce((sum, saving) => sum + saving.amount, 0);
    const savingsDiscipline = Math.min(Math.round(totalSavings / 100), 25);

    // Cash Flow Management (25 points max)
    const totalExpenses = userExpenses.reduce((sum, expense) => sum + expense.amount, 0);
    const cashFlowRatio = totalSavings / (totalExpenses || 1);
    const cashFlowManagement = Math.min(Math.round(cashFlowRatio * 10), 25);

    // Overdue Bills Penalty (20 points max)
    const overdueBills = userExpenses.filter(expense => 
      expense.dueDate && !expense.isPaid && moment().isAfter(expense.dueDate)
    );
    const overduePenalty = Math.min(overdueBills.length * 5, 20);

    const totalScore = billPaymentConsistency + savingsDiscipline + cashFlowManagement - overduePenalty;

    return {
      score: Math.max(0, totalScore),
      scoreFactors: {
        billPaymentConsistency,
        savingsDiscipline,
        cashFlowManagement,
        overdueBills: overduePenalty
      }
    };
  } catch (error) {
    console.error('Error calculating Samarthan Score:', error);
    return {
      score: 0,
      scoreFactors: {
        billPaymentConsistency: 0,
        savingsDiscipline: 0,
        cashFlowManagement: 0,
        overdueBills: 0
      }
    };
  }
};

// Routes

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development'
  });
});

// Google OAuth login
app.post('/api/auth/google', async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({ message: 'ID token is required' });
    }

    const googleUser = await verifyGoogleToken(idToken);
    
    // Find or create user
    let user = users.find(u => u.googleId === googleUser.googleId);
    
    if (!user) {
      user = {
        id: generateId(),
        googleId: googleUser.googleId,
        email: googleUser.email,
        name: googleUser.name,
        picture: googleUser.picture,
        emailVerified: googleUser.emailVerified,
        createdAt: new Date()
      };
      users.push(user);
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, googleId: user.googleId },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '7d' }
    );

    res.json({
      token,
      user: {
        id: user.id,
        googleId: user.googleId,
        email: user.email,
        name: user.name,
        picture: user.picture
      }
    });
  } catch (error) {
    console.error('Google auth error:', error);
    res.status(401).json({ message: 'Authentication failed', error: error.message });
  }
});

// Get current user
app.get('/api/user', authenticateToken, (req, res) => {
  try {
    const user = users.find(u => u.id === req.user.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json({
      id: user.id,
      googleId: user.googleId,
      email: user.email,
      name: user.name,
      picture: user.picture
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ message: 'Error fetching user' });
  }
});

// Expenses routes
app.get('/api/expenses', authenticateToken, (req, res) => {
  try {
    const userExpenses = expenses.filter(expense => expense.userId === req.user.userId)
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    res.json(userExpenses);
  } catch (error) {
    console.error('Get expenses error:', error);
    res.status(500).json({ message: 'Error fetching expenses' });
  }
});

app.post('/api/expenses', authenticateToken, (req, res) => {
  try {
    const { description, amount, category, dueDate } = req.body;

    if (!validateRequired(description) || !validateAmount(amount) || !validateRequired(category)) {
      return res.status(400).json({ message: 'Invalid input data' });
    }

    const expense = {
      id: generateId(),
      userId: req.user.userId,
      description: description.trim(),
      amount: parseFloat(amount),
      category: category.trim(),
      dueDate: dueDate ? new Date(dueDate) : null,
      isPaid: false,
      paidDate: null,
      createdAt: new Date()
    };

    expenses.push(expense);
    res.status(201).json(expense);
  } catch (error) {
    console.error('Create expense error:', error);
    res.status(500).json({ message: 'Error creating expense' });
  }
});

app.put('/api/expenses/:id/paid', authenticateToken, (req, res) => {
  try {
    const expenseIndex = expenses.findIndex(expense => 
      expense.id === req.params.id && expense.userId === req.user.userId
    );
    
    if (expenseIndex === -1) {
      return res.status(404).json({ message: 'Expense not found' });
    }

    expenses[expenseIndex].isPaid = true;
    expenses[expenseIndex].paidDate = new Date();

    res.json({ message: 'Expense marked as paid', expense: expenses[expenseIndex] });
  } catch (error) {
    console.error('Mark expense as paid error:', error);
    res.status(500).json({ message: 'Error updating expense' });
  }
});

app.delete('/api/expenses/:id', authenticateToken, (req, res) => {
  try {
    const expenseIndex = expenses.findIndex(expense => 
      expense.id === req.params.id && expense.userId === req.user.userId
    );
    
    if (expenseIndex === -1) {
      return res.status(404).json({ message: 'Expense not found' });
    }

    expenses.splice(expenseIndex, 1);
    res.json({ message: 'Expense deleted successfully' });
  } catch (error) {
    console.error('Delete expense error:', error);
    res.status(500).json({ message: 'Error deleting expense' });
  }
});

// Savings routes
app.get('/api/savings', authenticateToken, (req, res) => {
  try {
    const userSavings = savings.filter(saving => saving.userId === req.user.userId)
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    res.json(userSavings);
  } catch (error) {
    console.error('Get savings error:', error);
    res.status(500).json({ message: 'Error fetching savings' });
  }
});

app.post('/api/savings', authenticateToken, (req, res) => {
  try {
    const { amount, type = 'manual', description } = req.body;

    if (!validateAmount(amount)) {
      return res.status(400).json({ message: 'Invalid amount' });
    }

    const saving = {
      id: generateId(),
      userId: req.user.userId,
      amount: parseFloat(amount),
      type: type.trim(),
      description: description ? description.trim() : null,
      createdAt: new Date()
    };

    savings.push(saving);
    res.status(201).json(saving);
  } catch (error) {
    console.error('Create savings error:', error);
    res.status(500).json({ message: 'Error creating savings' });
  }
});

app.delete('/api/savings/:id', authenticateToken, (req, res) => {
  try {
    const savingIndex = savings.findIndex(saving => 
      saving.id === req.params.id && saving.userId === req.user.userId
    );
    
    if (savingIndex === -1) {
      return res.status(404).json({ message: 'Savings not found' });
    }

    savings.splice(savingIndex, 1);
    res.json({ message: 'Savings deleted successfully' });
  } catch (error) {
    console.error('Delete savings error:', error);
    res.status(500).json({ message: 'Error deleting savings' });
  }
});

// Samarthan Score routes
app.get('/api/samarthan-score', authenticateToken, (req, res) => {
  try {
    const scoreData = calculateSamarthanScore(req.user.userId);
    
    // Save or update score in memory
    const existingScoreIndex = scores.findIndex(score => score.userId === req.user.userId);
    const scoreRecord = {
      userId: req.user.userId,
      score: scoreData.score,
      scoreFactors: scoreData.scoreFactors,
      lastUpdated: new Date()
    };
    
    if (existingScoreIndex !== -1) {
      scores[existingScoreIndex] = scoreRecord;
    } else {
      scores.push(scoreRecord);
    }

    res.json({
      samarthanScore: scoreData.score,
      scoreFactors: scoreData.scoreFactors,
      lastUpdated: new Date().toISOString()
    });
  } catch (error) {
    console.error('Get Samarthan Score error:', error);
    res.status(500).json({ message: 'Error calculating Samarthan Score' });
  }
});

// Dashboard data
app.get('/api/dashboard', authenticateToken, (req, res) => {
  try {
    const userExpenses = expenses.filter(expense => expense.userId === req.user.userId)
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    const userSavings = savings.filter(saving => saving.userId === req.user.userId)
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    const scoreData = calculateSamarthanScore(req.user.userId);

    const totalExpenses = userExpenses.reduce((sum, expense) => sum + expense.amount, 0);
    const totalSavings = userSavings.reduce((sum, saving) => sum + saving.amount, 0);

    res.json({
      samarthanScore: scoreData.score,
      scoreFactors: scoreData.scoreFactors,
      recentExpenses: userExpenses.slice(0, 5),
      recentSavings: userSavings.slice(0, 5),
      totalExpenses,
      totalSavings
    });
  } catch (error) {
    console.error('Get dashboard data error:', error);
    res.status(500).json({ message: 'Error fetching dashboard data' });
  }
});

// Analytics
app.get('/api/analytics', authenticateToken, (req, res) => {
  try {
    const userExpenses = expenses.filter(expense => expense.userId === req.user.userId);
    const userSavings = savings.filter(saving => saving.userId === req.user.userId);

    // Monthly expenses
    const monthlyExpenses = {};
    userExpenses.forEach(expense => {
      const month = moment(expense.createdAt).format('YYYY-MM');
      monthlyExpenses[month] = (monthlyExpenses[month] || 0) + expense.amount;
    });

    // Monthly savings
    const monthlySavings = {};
    userSavings.forEach(saving => {
      const month = moment(saving.createdAt).format('YYYY-MM');
      monthlySavings[month] = (monthlySavings[month] || 0) + saving.amount;
    });

    // Category breakdown
    const categoryBreakdown = {};
    userExpenses.forEach(expense => {
      categoryBreakdown[expense.category] = (categoryBreakdown[expense.category] || 0) + expense.amount;
    });

    res.json({
      monthlyExpenses,
      monthlySavings,
      categoryBreakdown
    });
  } catch (error) {
    console.error('Get analytics error:', error);
    res.status(500).json({ message: 'Error fetching analytics' });
  }
});

// Notifications
app.get('/api/notifications', authenticateToken, (req, res) => {
  try {
    const userExpenses = expenses.filter(expense => expense.userId === req.user.userId);
    const userSavings = savings.filter(saving => saving.userId === req.user.userId);
    const notifications = [];

    // Bill due date reminders
    const upcomingBills = userExpenses.filter(expense => 
      expense.dueDate && !expense.isPaid && 
      moment(expense.dueDate).diff(moment(), 'days') <= 3 &&
      moment(expense.dueDate).diff(moment(), 'days') >= 0
    );

    upcomingBills.forEach(bill => {
      notifications.push({
        id: generateId(),
        type: 'reminder',
        title: 'Bill Due Soon',
        message: `${bill.description} is due in ${moment(bill.dueDate).diff(moment(), 'days')} days`,
        timestamp: new Date().toISOString(),
        priority: 'medium'
      });
    });

    // Overdue bills
    const overdueBills = userExpenses.filter(expense => 
      expense.dueDate && !expense.isPaid && moment().isAfter(expense.dueDate)
    );

    overdueBills.forEach(bill => {
      notifications.push({
        id: generateId(),
        type: 'alert',
        title: 'Overdue Bill',
        message: `${bill.description} is overdue by ${moment().diff(moment(bill.dueDate), 'days')} days`,
        timestamp: new Date().toISOString(),
        priority: 'high'
      });
    });

    // Savings tips
    const totalSavings = userSavings.reduce((sum, saving) => sum + saving.amount, 0);
    
    if (totalSavings > 0) {
      notifications.push({
        id: generateId(),
        type: 'tip',
        title: 'Savings Achievement',
        message: `Great job! You've saved ₹${totalSavings.toFixed(0)} this month`,
        timestamp: new Date().toISOString(),
        priority: 'low'
      });
    }

    res.json(notifications);
  } catch (error) {
    console.error('Get notifications error:', error);
    res.status(500).json({ message: 'Error fetching notifications' });
  }
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ 
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  process.exit(0);
});

app.listen(PORT, () => {
  console.log(`🚀 Samarthan API server running on port ${PORT}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/api/health`);
  console.log(`🌐 API Base URL: http://localhost:${PORT}/api`);
  console.log(`📱 Ready for Flutter app connection!`);
  console.log(`💾 Using in-memory storage (code-only, no external database)`);
});
