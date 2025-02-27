// ignore_for_file: use_build_context_synchronously

import 'package:bookmywod_admin/utils/shared_preference_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bookmywod_admin/bloc/auth_bloc.dart';
import 'package:bookmywod_admin/bloc/events/auth_event_forgot_password.dart';
import 'package:bookmywod_admin/bloc/events/auth_event_login.dart';
import 'package:bookmywod_admin/bloc/events/auth_event_should_register.dart';
import 'package:bookmywod_admin/bloc/events/auth_event_signin_with_google.dart';
import 'package:bookmywod_admin/bloc/states/auth_state.dart';
import 'package:bookmywod_admin/bloc/states/auth_state_logged_out.dart';
import 'package:bookmywod_admin/services/auth/auth_exceptions.dart';
import 'package:bookmywod_admin/shared/constants/colors.dart';
import 'package:bookmywod_admin/shared/constants/regex.dart';
import 'package:bookmywod_admin/shared/custom_text_field.dart';
import 'package:bookmywod_admin/shared/custom_button.dart';
import 'package:bookmywod_admin/shared/show_snackbar.dart';
import 'package:flutter_svg/svg.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool rememberMe = false;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _loadSaveCredentials();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSaveCredentials() async {
    final savedEmail = await SharedPreferrenceHelper.getString('email');
    final savedPassword = await SharedPreferrenceHelper.getString('password');
    final savedRememberMe =
        await SharedPreferrenceHelper.getBool('remember_me') ?? false;

    if (savedRememberMe) {
      setState(() {
        _emailController.text = savedEmail ?? '';
        _passwordController.text = savedPassword ?? '';
        rememberMe = savedRememberMe;
      });
    }
  }

  Future<void> _saveCredentials() async {
    if (rememberMe) {
      await SharedPreferrenceHelper.setString('email', _emailController.text);
      await SharedPreferrenceHelper.setString(
          'password', _passwordController.text);
      await SharedPreferrenceHelper.setBool('remember_me', rememberMe);
    } else {
      await SharedPreferrenceHelper.remove('email');
      await SharedPreferrenceHelper.remove('password');
      await SharedPreferrenceHelper.remove('remember_me');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          await _saveCredentials();
          if (state.exception is UserNotFoundAuthException) {
            await showSnackbar(
              context,
              'User not found',
              type: SnackbarType.error,
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showSnackbar(
              context,
              'Cannot find a user with the credentials',
              type: SnackbarType.error,
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showSnackbar(
              context,
              'Wrong Credentials',
              type: SnackbarType.error,
            );
          } else if (state.exception is GenericAuthException) {
            await showSnackbar(
              context,
              'Authentication failed',
              type: SnackbarType.error,
            );
          }
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 120,
                  ),
                  Image.asset(
                    'assets/logo.png',
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Sign In',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.09),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome back! Log in to continue',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.055),
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    label: 'Email Address',
                    prefixIcon: Icon(Icons.email),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email can't be empty";
                      } else if (!emailValid.hasMatch(value)) {
                        return "Invalid email provided";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextField(
                    label: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    controller: _passwordController,
                    obscureText: true,
                    isVisible: _isPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid password';
                      } else {
                        return null;
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (value) async {
                              setState(() {
                                rememberMe = value!;
                              });
                              await SharedPreferrenceHelper.setBool(
                                  'remember_me', rememberMe);
                              if (!rememberMe) {
                                await SharedPreferrenceHelper.remove('email');
                                await SharedPreferrenceHelper.remove(
                                    'password');
                              }
                            },
                            activeColor: customBlue,
                            checkColor: Colors.black,
                          ),
                          Text(
                            'Remember me',
                            style: TextStyle(),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                AuthEventForgotPassword(),
                              );
                        },
                        child: Text(
                          'Forgot Password',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomButton(
                      text: 'Sign In',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final email = _emailController.text;
                          final password = _passwordController.text;
                          context.read<AuthBloc>().add(
                                AuthEventLogin(
                                  email: email,
                                  password: password,
                                ),
                              );
                        }
                      }),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text(
                      'Or',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialButton('assets/auth/google.svg', () {
                        context.read<AuthBloc>().add(
                              AuthEventSignInWithGoogle(),
                            );
                      }),
                      _buildSocialButton('assets/auth/facebook.svg', () {}),
                      _buildSocialButton('assets/auth/apple.svg', () {}),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don’t have any account? ",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                AuthEventShouldRegister(),
                              );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: customBlue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
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

Widget _buildSocialButton(String assetPath, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: customGrey,
        shape: BoxShape.circle,
        border: Border.all(
          color: customGrey,
          width: 8,
        ),
      ),
      child: SvgPicture.asset(
        assetPath,
        width: 30,
        height: 30,
      ),
    ),
  );
}
