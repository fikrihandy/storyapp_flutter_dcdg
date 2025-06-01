import 'package:declarative_navigation/data/model/register_response.dart';

sealed class RegisterResultState {}

class RegisterNoneState extends RegisterResultState {}

class RegisterLoadingState extends RegisterResultState {}

class RegisterErrorState extends RegisterResultState {
  final String error;

  RegisterErrorState(this.error);
}

class RegisterLoadedState extends RegisterResultState {
  final RegisterResponse data;

  RegisterLoadedState(this.data);
}
