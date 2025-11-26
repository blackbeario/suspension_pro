import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/auth/presentation/auth_view_model.dart';
import 'package:ridemetrx/features/auth/presentation/screens/signup_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _hidePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _hidePassword = !_hidePassword);
  }

  Future<void> _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authViewModelProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      // Check for errors after sign in attempt
      final authState = ref.read(authViewModelProvider);
      if (authState.errorMessage != null && mounted) {
        _showLoginFailure(
          context,
          authState.errorMessage!,
          authState.errorDetails,
        );
      }
    }
  }

  void _navigateToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

    return Scaffold(
      backgroundColor: Color.fromRGBO(50, 39, 116, 100),
      body: Container(
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/josh_lower_hareball.jpg'),
            alignment: Alignment.center,
            fit: BoxFit.fitHeight,
          ),
        ),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: Text(
                'RideMetrx',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 300, 0, 20),
              child: Text(
                'Record and share your bike \nsuspension products and settings',
                style: TextStyle(
                  color: Colors.white,
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(0, 0),
                      blurRadius: 5.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SafeArea(
              child: Form(
                key: _formKey,
                child: Center(
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextFormField(
                            key: const ValueKey('emailField'),
                            controller: _emailController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.only(left: 10, right: 10),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(style: BorderStyle.none),
                                borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                              ),
                              hintText: 'email',
                              hintStyle: TextStyle(fontWeight: FontWeight.w300),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            style: style.copyWith(color: Colors.black),
                            validator: (email) {
                              if (email == null || email.isEmpty) {
                                return 'Enter email address';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextFormField(
                            key: const ValueKey('passwordField'),
                            controller: _passwordController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.only(left: 10, right: 10),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(style: BorderStyle.none),
                                borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                              ),
                              hintText: 'password',
                              hintStyle: TextStyle(fontWeight: FontWeight.w300),
                              suffixIcon: TextButton(
                                onPressed: _togglePasswordVisibility,
                                style: ButtonStyle(alignment: Alignment.centerRight),
                                child: Icon(
                                  _hidePassword ? Icons.lock : Icons.lock_open,
                                  color: CupertinoColors.inactiveGray,
                                ),
                              ),
                            ),
                            obscureText: _hidePassword,
                            keyboardType: TextInputType.visiblePassword,
                            style: style.copyWith(color: Colors.black),
                            validator: (password) {
                              if (password == null || password.isEmpty) {
                                return 'Enter password';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
                          child: ElevatedButton(
                            key: const ValueKey('signInButton'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[400],
                            ),
                            onPressed: authState.isLoading ? null : _handleSignIn,
                            child: authState.isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : Text(
                                    "Sign In",
                                    style: style.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        TextButton(
                          key: const ValueKey('createAccountButton'),
                          child: Text(
                            'Create New Account',
                            style: style.copyWith(color: Colors.white, fontSize: 14),
                          ),
                          onPressed: _navigateToSignUp,
                        ),
                        Text(
                          'Version: Beta 0.1.5',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLoginFailure(
    BuildContext context,
    String message,
    String? details,
  ) async {
    return showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: Text(message),
          content: details != null ? Text(details) : null,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
                // Clear error after showing
                ref.read(authViewModelProvider.notifier).clearError();
              },
            ),
          ],
        );
      },
    );
  }
}
