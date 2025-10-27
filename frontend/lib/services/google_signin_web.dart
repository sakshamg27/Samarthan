import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:convert';
import 'dart:async';

class GoogleSignInWeb {
  static const String _clientId = 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com';
  
  static Future<Map<String, dynamic>?> signIn() async {
    try {
      // For demo purposes, return mock data
      // In production, replace this with real Google OAuth
      return await _mockGoogleSignIn();
      
      // Uncomment below for real Google OAuth:
      // return await _realGoogleSignIn();
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
  
  static Future<Map<String, dynamic>?> _realGoogleSignIn() async {
    try {
      // Wait for Google Identity Services to load
      await _waitForGoogleIdentityServices();
      
      // Use Google's One Tap
      final credential = await _showGoogleSignIn();
      
      if (credential != null) {
        // Decode the JWT credential
        final payload = _decodeJwtPayload(credential);
        return payload;
      }
      
      return null;
    } catch (e) {
      // Real Google Sign-In error - handle silently in production
      return null;
    }
  }
  
  static Future<void> _waitForGoogleIdentityServices() async {
    // Wait for Google Identity Services to be available
    int attempts = 0;
    while (attempts < 50) { // 5 seconds max
      try {
        if (js.context.hasProperty('google') && 
            js.context['google'].hasProperty('accounts') &&
            js.context['google']['accounts'].hasProperty('id')) {
          return;
        }
      } catch (e) {
        // Continue waiting
      }
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    throw Exception('Google Identity Services not loaded');
  }
  
  static Future<String?> _showGoogleSignIn() async {
    final completer = Completer<String?>();
    
    try {
      // Initialize Google Sign-In
      js.context.callMethod('google.accounts.id.initialize', [
        js.JsObject.jsify({
          'client_id': _clientId,
          'callback': js.allowInterop((js.JsObject response) {
            try {
              final credential = response['credential'] as String?;
              completer.complete(credential);
            } catch (e) {
              completer.complete(null);
            }
          }),
          'auto_select': false,
          'cancel_on_tap_outside': true,
        })
      ]);
      
      // Show the One Tap prompt
      js.context.callMethod('google.accounts.id.prompt', [
        js.allowInterop((js.JsObject notification) {
          // Handle notification if needed
        })
      ]);
      
      // Set a timeout
      Timer(const Duration(seconds: 30), () {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });
      
      return completer.future;
    } catch (e) {
      completer.complete(null);
      return completer.future;
    }
  }
  
  static Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      // Split the JWT token
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT token');
      }
      
      // Decode the payload (second part)
      final payload = parts[1];
      
      // Add padding if needed
      final paddedPayload = payload.padRight(
        payload.length + (4 - payload.length % 4) % 4,
        '=',
      );
      
      // Decode base64
      final decodedBytes = base64Url.decode(paddedPayload);
      final decodedString = utf8.decode(decodedBytes);
      
      return json.decode(decodedString);
    } catch (e) {
      throw Exception('Failed to decode JWT payload: $e');
    }
  }
}

// Helper class for Completer
class Completer<T> {
  final _completer = Future<T>.sync(() => throw UnimplementedError());
  T? _value;
  bool _isCompleted = false;
  
  Future<T> get future => _completer;
  
  bool get isCompleted => _isCompleted;
  
  void complete(T value) {
    if (!_isCompleted) {
      _value = value;
      _isCompleted = true;
    }
  }
}
