import 'package:declarative_navigation/data/api/api_services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import '../data/model/login_model.dart';
import '../static/strings.dart';
import '../static/login_result_state.dart';

class LoginProvider extends ChangeNotifier {
  final ApiServices _apiServices;

  LoginProvider(this._apiServices);

  LoginResultState _resultState = LoginNoneState();

  LoginResultState get resultState => _resultState;

  Future<void> fetchLogin(LoginModel user) async {
    try {
      _resultState = LoginLoadingState();
      notifyListeners();
      final result = await _apiServices.login(user);

      if (result.error) {
        _resultState = LoginErrorState(result.message);
        notifyListeners();
      } else {
        _resultState = LoginLoadedState(result);
        notifyListeners();
      }
    } on ClientException {
      _resultState = LoginErrorState(clientExceptionErrorMessage);
      notifyListeners();
    } on Exception catch (e) {
      _resultState = LoginErrorState(e.toString());
      notifyListeners();
    }
  }
}
