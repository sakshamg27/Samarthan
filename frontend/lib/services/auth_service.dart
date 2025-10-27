import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/models.dart';
import 'google_signin_web.dart';

class AuthService {
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(Map<String, dynamic>.from(
        Uri.splitQueryString(userJson)
      ));
    }
    return null;
  }

  Future<void> saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, user.toJson().toString());
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<bool> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In process...');
      
      // Use web-compatible Google Sign-In
      final googleUser = await GoogleSignInWeb.signIn();
      
      if (googleUser == null) {
        print('Google Sign-In returned null - user cancelled or error occurred');
        return false; // User cancelled the sign-in
      }

      print('Google user data received: $googleUser');

      // Extract user data from Google response
      final String? googleId = googleUser['sub'];
      final String? email = googleUser['email'];
      final String? name = googleUser['name'];
      final String? picture = googleUser['picture'];
      
      if (googleId == null || email == null) {
        print('Missing required user data - googleId: $googleId, email: $email');
        return false;
      }

      print('Sending user data to backend...');
      // Send Google user data to backend
      final response = await ApiService.googleSignIn(idToken: googleId);
      final token = response['token'];
      final userData = response['user'];
      
      print('Backend response received successfully');
      final user = User.fromJson(userData);
      await saveAuthData(token, user);
      print('Authentication completed successfully');
      return true;
    } catch (e) {
      print('Google Sign-In error: $e');
      // Google Sign-In error - handle silently in production
      return false;
    }
  }

  Future<void> logout() async {
    await clearAuthData();
  }
}
