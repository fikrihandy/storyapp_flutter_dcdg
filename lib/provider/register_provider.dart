import '../data/api/api_services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import '../data/model/register_model.dart';
import '../static/strings.dart';
import '../static/register_result_state.dart';

class RegisterProvider extends ChangeNotifier {
  final ApiServices _apiServices;

  RegisterProvider(this._apiServices);

  RegisterResultState _resultState = RegisterNoneState();

  RegisterResultState get resultState => _resultState;

  Future<void> fetchRegister(RegisterModel user) async {
    try {
      _resultState = RegisterLoadingState();
      notifyListeners();
      final result = await _apiServices.register(user);

      if (result.error) {
        _resultState = RegisterErrorState(result.message);
        notifyListeners();
      } else {
        _resultState = RegisterLoadedState(result);
        notifyListeners();
      }
    } on ClientException {
      _resultState = RegisterErrorState(clientExceptionErrorMessage);
      notifyListeners();
    } on Exception catch (e) {
      _resultState = RegisterErrorState(e.toString());
      notifyListeners();
    }
  }
}
