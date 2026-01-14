import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// Authentication Provider using Provider pattern
class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  
  AuthProvider({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Initialize - check if user is already logged in
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');

      if (accessToken != null && refreshToken != null) {
        // Check if token is expired
        if (JwtDecoder.isExpired(accessToken)) {
          // Try to refresh
          _apiService.setTokens(accessToken, refreshToken);
          final refreshed = await _apiService.refreshAccessToken();
          if (refreshed) {
            final newAccessToken = prefs.getString('access_token');
            if (newAccessToken != null) {
              await prefs.setString('access_token', newAccessToken);
            }
          } else {
            // Refresh failed, clear tokens
            await _clearStoredTokens();
            _isLoading = false;
            notifyListeners();
            return;
          }
        } else {
          _apiService.setTokens(accessToken, refreshToken);
        }

        // Get user profile
        try {
          _currentUser = await _apiService.getCurrentUser();
        } catch (e) {
          // Failed to get user, clear tokens
          await _clearStoredTokens();
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _currentUser = null; // Reset user
    notifyListeners();

    try {
      // Step 1: Login to get tokens
      final response = await _apiService.login(username, password);
      
      final accessToken = response['access'];
      final refreshToken = response['refresh'];

      if (accessToken == null || refreshToken == null) {
        _errorMessage = 'فشل في الحصول على tokens من الخادم';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Store tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);

      // Set tokens in API service
      _apiService.setTokens(accessToken, refreshToken);

      // Step 2: Get user profile
      try {
        print('🔐 [Auth] Attempting to get user profile...');
        developer.log('Attempting to get user profile...', name: 'AuthProvider');
        _currentUser = await _apiService.getCurrentUser();
        print('✅ [Auth] User profile loaded: ${_currentUser?.username}, role: ${_currentUser?.role}');
        developer.log('User profile loaded: ${_currentUser?.username}', name: 'AuthProvider');
        
        // Verify user was loaded
        if (_currentUser == null) {
          print('❌ [Auth] User profile is null after loading');
          developer.log('User profile is null after loading', name: 'AuthProvider');
          await _clearStoredTokens();
          _apiService.clearTokens();
          _errorMessage = 'فشل في جلب معلومات المستخدم: البيانات فارغة';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        
        print('✅ [Auth] User authenticated successfully: ${_currentUser?.username}');
      } catch (e, stackTrace) {
        print('❌ [Auth] Error getting user profile: $e');
        print('📋 [Auth] Stack trace: $stackTrace');
        developer.log('Error getting user profile: $e', name: 'AuthProvider', error: e);
        // Failed to get user profile - clear tokens and show error
        await _clearStoredTokens();
        _apiService.clearTokens();
        _currentUser = null;
        
        // Extract error message
        String errorMsg = e.toString();
        if (errorMsg.contains('404') || errorMsg.contains('Profile not found')) {
          _errorMessage = 'ملف المستخدم غير موجود. يرجى إنشاء ملف شخصي من لوحة التحكم.';
        } else if (errorMsg.contains('401') || errorMsg.contains('Unauthorized')) {
          _errorMessage = 'غير مصرح بالوصول. يرجى المحاولة مرة أخرى.';
        } else {
          _errorMessage = 'فشل في جلب معلومات المستخدم:\n$errorMsg';
        }
        
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Success - user is loaded
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _currentUser = null;
      _errorMessage = 'خطأ في تسجيل الدخول: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _clearStoredTokens();
    _apiService.clearTokens();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear stored tokens
  Future<void> _clearStoredTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }
  
  // Get ApiService instance (for use in screens)
  ApiService get apiService => _apiService;
  
  // Refresh user profile
  Future<void> refreshProfile() async {
    try {
      _currentUser = await _apiService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      developer.log('Error refreshing profile: $e', name: 'AuthProvider');
    }
  }
}

