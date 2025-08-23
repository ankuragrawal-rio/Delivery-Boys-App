import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../data/models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final Dio _dio = Dio();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      // In a real app, you'd parse JSON here
      // For now, return null and implement mock data
    }
    return null;
  }

  Future<bool> sendOtp(String phoneNumber) async {
    try {
      // Mock implementation - always return success
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    try {
      // Mock implementation - accept any 6-digit OTP
      if (otp.length == 6) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
        
        // Create mock user data
        final mockUser = UserModel(
          userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
          phoneNumber: phoneNumber,
          fullName: 'Delivery Boy',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await prefs.setString(_userKey, mockUser.toJson().toString());
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
