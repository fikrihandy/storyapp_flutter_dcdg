import 'package:shared_preferences/shared_preferences.dart';
import '../data/model/user_token.dart';

class SharedPrefRepository {
  static const String _sessionKey = "session";
  static const String _userTokenKey = "user_token";

  Future<bool> isUserLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_sessionKey) ?? false;
  }

  Future<bool> saveSession() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setBool(_sessionKey, true);
  }

  Future<bool> clearLoginSession() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setBool(_sessionKey, false);
  }

  Future<bool> saveUserToken(UserToken user) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setString(_userTokenKey, user.toJson());
  }

  Future<bool> deleteUserToken() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.remove(_userTokenKey);
  }

  Future<UserToken?> fetchUserToken() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final userTokenJson = sharedPreferences.getString(_userTokenKey);
    if (userTokenJson == null || userTokenJson.isEmpty) {
      return null;
    }
    try {
      return UserToken.fromJson(userTokenJson);
    } catch (e) {
      return null;
    }
  }
}
