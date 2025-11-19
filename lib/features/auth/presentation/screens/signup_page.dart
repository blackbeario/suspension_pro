import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suspension_pro/features/auth/presentation/auth_view_model.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _hidePassword = !_hidePassword);
  }

  Future<void> _handleSignUp() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showSignUpError(context, 'Please enter both email and password');
      return;
    }

    await ref.read(authViewModelProvider.notifier).signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

    // Check for errors or success
    final authState = ref.read(authViewModelProvider);
    if (authState.errorMessage != null && mounted) {
      _showSignUpError(
        context,
        authState.errorDetails ?? authState.errorMessage!,
      );
    } else if (!authState.isLoading && mounted) {
      // Success - navigate back to login
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final TextStyle style = TextStyle(fontSize: 20.0);

    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/cupcake.jpg"),
            alignment: Alignment.topCenter,
            fit: BoxFit.fitHeight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(30, 450, 30, 0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CupertinoTextField(
                    key: const ValueKey('signUpEmailField'),
                    controller: _emailController,
                    padding: EdgeInsets.all(10.0),
                    placeholder: "email",
                    keyboardType: TextInputType.emailAddress,
                    style: style.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CupertinoTextField(
                    key: const ValueKey('signUpPasswordField'),
                    padding: EdgeInsets.all(10.0),
                    controller: _passwordController,
                    placeholder: "password",
                    obscureText: _hidePassword,
                    keyboardType: TextInputType.visiblePassword,
                    style: style.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    suffix: TextButton(
                      onPressed: _togglePasswordVisibility,
                      child: Icon(
                        _hidePassword ? Icons.lock : Icons.lock_open,
                        color: CupertinoColors.inactiveGray,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 0.0),
                  child: Material(
                    elevation: 1.0,
                    borderRadius: BorderRadius.circular(8.0),
                    color: CupertinoColors.activeBlue,
                    child: CupertinoButton(
                      key: const ValueKey('signUpButton'),
                      onPressed: authState.isLoading ? null : _handleSignUp,
                      child: authState.isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              "Sign Up",
                              style: TextStyle(color: Colors.white, fontSize: 18.0),
                            ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSignUpError(BuildContext context, String message) async {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Sign Up Error'),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Okay'),
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
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
