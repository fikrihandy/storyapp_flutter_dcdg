import 'package:flutter/services.dart';
import '../others/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/model/register_model.dart';
import '../../provider/register_provider.dart';
import '../../static/register_result_state.dart';
import '../../static/strings.dart';

class RegisterScreen extends StatefulWidget {
  final Function() onRegister;
  final Function() onLogin;

  const RegisterScreen({
    super.key,
    required this.onRegister,
    required this.onLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(registerPage),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return enterYour(name);
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: name,
                    ),
                  ),
                  TextFormField(
                    controller: emailController,
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
                    controller: passwordController,
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
                  context.watch<RegisterProvider>().resultState
                          is RegisterLoadingState
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () async {
                            SystemChannels.textInput.invokeMethod(
                              'TextInput.hide',
                            );
                            if (formKey.currentState!.validate()) {
                              final RegisterModel user = RegisterModel(
                                name: nameController.text,
                                email: emailController.text,
                                password: passwordController.text,
                              );

                              final register = context.read<RegisterProvider>();
                              await register.fetchRegister(user);

                              final resultState = register.resultState;

                              if (resultState is RegisterErrorState) {
                                showSnackBar(context, resultState.error);
                              } else if (resultState is RegisterLoadedState) {
                                showSnackBar(context, resultState.data.message);
                                widget.onRegister();
                              }
                            }
                          },
                          child: const Text(registerText),
                        ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => widget.onLogin(),
                    child: const Text(loginText),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
