import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService extends ChangeNotifier {
  SessionService._();

  static final SessionService instance = SessionService._();

  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  late SharedPreferences _preferences;
  bool _isInitialized = false;
  bool _isLoggedIn = false;
  String? _userId;
  String? _userEmail;

  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasValidSession =>
      _isLoggedIn && _userId != null && _userId!.isNotEmpty;
  String? get userId => _userId;
  String? get userEmail => _userEmail;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    _isLoggedIn = _preferences.getBool(_isLoggedInKey) ?? false;
    _userId = _preferences.getString(_userIdKey);
    _userEmail = _preferences.getString(_userEmailKey);
    if (_isLoggedIn && (_userId == null || _userId!.isEmpty)) {
      // Self-heal inconsistent persisted session.
      _isLoggedIn = false;
      _userEmail = null;
      await _preferences.remove(_isLoggedInKey);
      await _preferences.remove(_userIdKey);
      await _preferences.remove(_userEmailKey);
    }
    _isInitialized = true;
  }

  Future<void> saveLogin({
    required String userId,
    required String userEmail,
  }) async {
    _isLoggedIn = true;
    _userId = userId;
    _userEmail = userEmail;

    await _preferences.setBool(_isLoggedInKey, true);
    await _preferences.setString(_userIdKey, userId);
    await _preferences.setString(_userEmailKey, userEmail);
    notifyListeners();
  }

  Future<void> clearSession() async {
    _isLoggedIn = false;
    _userId = null;
    _userEmail = null;

    await _preferences.remove(_isLoggedInKey);
    await _preferences.remove(_userIdKey);
    await _preferences.remove(_userEmailKey);
    notifyListeners();
  }
}
