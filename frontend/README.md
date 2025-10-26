# Samarthan Frontend

## 🌐 Production-Ready Flutter Web App

This is the frontend Flutter web application for Samarthan Family Finance OS.

## 📦 What's Included

- ✅ **lib/** - Flutter source code
- ✅ **web/** - Web configuration files
- ✅ **pubspec.yaml** - Flutter dependencies
- ✅ **pubspec.lock** - Dependency lock file

## 🚀 Quick Start

### 1. Install Flutter
Make sure Flutter is installed on your system.

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Build for Web
```bash
flutter build web --release
```

### 4. Serve Locally (Optional)
```bash
flutter run -d chrome --web-port=8080
```

## 🔧 Configuration

### API Endpoint
Update the API URL in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://your-backend-url.onrender.com/api';
```

## 📱 Features

- ✅ **Digital Khata** - Expense tracking with categories
- ✅ **Digital Gullak** - Savings management
- ✅ **Samarthan Score** - Alternative credit scoring
- ✅ **Bill Payments** - Mark bills as paid
- ✅ **Analytics** - Monthly reports and insights
- ✅ **Notifications** - Bill reminders and tips
- ✅ **Bilingual UI** - English and Hindi support

## 🚀 Deployment

### Vercel (Recommended)
1. Connect GitHub repository
2. Set framework: Other
3. Set root directory: `frontend`
4. Set build command: `flutter build web --release`
5. Set output directory: `build/web`
6. Deploy!

### Environment Variables
```
API_BASE_URL=https://your-backend-url.onrender.com/api
```

**Total Monthly Cost: $0** (Free tier)

## 🎨 UI Features

- ✅ **Material Design 3** - Modern UI components
- ✅ **Responsive Design** - Works on all devices
- ✅ **Hindi Support** - Bilingual interface
- ✅ **Dark/Light Theme** - Theme switching
- ✅ **Hover Effects** - Interactive elements
- ✅ **Gradient Backgrounds** - Beautiful visuals

## 📱 Supported Platforms

- ✅ **Web** - Chrome, Firefox, Safari, Edge
- ✅ **Mobile** - Responsive design
- ✅ **Tablet** - Optimized layouts

---

**Samarthan Family Finance OS** - Empowering families with financial management tools.
