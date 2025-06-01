import 'package:flutter/widgets.dart';
import '../data/model/user_token.dart';
import '../db/sharedpref_repository.dart';

class SharedPrefProvider extends ChangeNotifier {
  final SharedPrefRepository sharedPrefRepository;

  SharedPrefProvider(this.sharedPrefRepository);

  bool isLoadingLogout = false;
  bool isLoggedIn = false;

  Future<bool> saveUserToken(String token) async {
    final userState =
        await sharedPrefRepository.saveUserToken(UserToken(token: token));
    if (userState) {
      await sharedPrefRepository.saveSession();
    }
    isLoggedIn = await sharedPrefRepository.isUserLoggedIn();
    return isLoggedIn;
  }

  Future<bool> clearLoginSession() async {
    isLoadingLogout = true;
    notifyListeners();
    final logout = await sharedPrefRepository.clearLoginSession();
    if (logout) {
      await sharedPrefRepository.deleteUserToken();
    }
    isLoggedIn = await sharedPrefRepository.isUserLoggedIn();
    isLoadingLogout = false;
    notifyListeners();
    return !isLoggedIn;
  }

  Future<UserToken?> getUserToken() async {
    try {
      return await sharedPrefRepository.fetchUserToken();
    } catch (e) {
      return null;
    }
  }
}
