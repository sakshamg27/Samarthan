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
      // Use web-compatible Google Sign-In
      final googleUser = await GoogleSignInWeb.signIn();
      
      if (googleUser == null) {
        return false; // User cancelled the sign-in
      }

      // Extract user data from Google response
      final String? googleId = googleUser['sub'];
      final String? email = googleUser['email'];
      final String? name = googleUser['name'];
      final String? picture = googleUser['picture'];
      
      if (googleId == null || email == null) {
        return false;
      }

      // Send Google user data to backend
      final response = await ApiService.googleSignIn(idToken: googleId);
      final token = response['token'];
      final userData = response['user'];
      
      final user = User.fromJson(userData);
      await saveAuthData(token, user);
      return true;
    } catch (e) {
      // Google Sign-In error - handle silently in production
      return false;
    }
  }

  Future<void> logout() async {
    await clearAuthData();
  }
}
