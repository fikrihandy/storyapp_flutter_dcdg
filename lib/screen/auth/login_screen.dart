import 'package:declarative_navigation/provider/sharedpref_provider.dart';
import 'package:declarative_navigation/screen/others/snackbar.dart';
import 'package:declarative_navigation/static/login_result_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/model/login_model.dart';
import '../../provider/login_provider.dart';
import '../../static/strings.dart';

class LoginScreen extends StatefulWidget {
  final Function() onLoginSuccess;
  final Function() onNavigateToRegister;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onNavigateToRegister,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    SystemChannels.textInput.invokeMethod(
      'TextInput.hide',
    );
    if (_formKey.currentState!.validate()) {
      final loginProvider = context.read<LoginProvider>();
      final authProvider = context.read<SharedPrefProvider>();

      final loginData = LoginModel(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await loginProvider.fetchLogin(loginData);

      final loginResult = loginProvider.resultState;

      if (loginResult is LoginLoadedState) {
        final success = await authProvider
            .saveUserToken(loginResult.data.loginResult.token);
        if (success) {
          showSnackBar(context, loginResult.data.message);
          widget.onLoginSuccess();
        } else {
          showSnackBar(context, saveCredentialsError);
        }
      } else if (loginResult is LoginErrorState) {
        showSnackBar(context, loginResult.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(loginPage),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return enterYour(email);
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: email,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: password,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return enterYour(password);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                context.watch<LoginProvider>().resultState is LoginLoadingState
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _handleLogin,
                        child: const Text(loginText),
                      ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => widget.onNavigateToRegister(),
                  child: const Text(registerText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
