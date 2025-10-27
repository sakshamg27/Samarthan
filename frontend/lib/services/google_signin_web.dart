import 'dart:convert';
import 'dart:async';

class GoogleSignInWeb {
  static const String _clientId = 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com';
  
  static Future<Map<String, dynamic>?> signIn() async {
    try {
      // For demo purposes, return mock data
      // In production, replace this with real Google OAuth
      return await _mockGoogleSignIn();
    } catch (e) {
      // Log the error for debugging
      print('Google Sign-In Error: $e');
      // Google Sign-In error - handle silently in production
      return null;
    }
  }
  
  static Future<Map<String, dynamic>?> _mockGoogleSignIn() async {
    // Simulate Google Sign-In with mock data
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'sub': 'demo_user_123',
      'email': 'demo@samarthan.com',
      'name': 'Demo User',
      'picture': 'https://via.placeholder.com/150',
      'email_verified': true,
      'given_name': 'Demo',
      'family_name': 'User',
    };
  }
}
