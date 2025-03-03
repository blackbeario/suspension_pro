import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suspension_pro/views/auth/signup.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/src/provider.dart';
import 'package:suspension_pro/core/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage();

  createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _hidePassword = true;

  // Toggles the password show status
  void _toggle() {
    setState(() => _hidePassword = !_hidePassword);
  }

  // final bool kIsWeb = identical(0, 0.0);
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  TextEditingController _email = TextEditingController(text: '');
  TextEditingController _password = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(50, 39, 116, 100),
      key: _key,
      body: Container(
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/josh_lower_hareball.jpg'), alignment: Alignment.center, fit: BoxFit.fitHeight),
        ),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: Text(
                'Suspension Pro',
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
              child: Text('Record and share your bike \nsuspension products and settings',
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
                  textAlign: TextAlign.center),
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
                            controller: _email,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.only(left: 10, right: 10),
                                border: OutlineInputBorder(
                                    borderSide: const BorderSide(style: BorderStyle.none),
                                    borderRadius: const BorderRadius.all(Radius.circular(6.0))),
                                hintText: 'email',
                                hintStyle: TextStyle(fontWeight: FontWeight.w300)),
                            keyboardType: TextInputType.emailAddress,
                            style: style.copyWith(color: Colors.black),
                            validator: (_email) {
                              if (_email == null || _email.isEmpty) return 'Enter email address';
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextFormField(
                            key: const ValueKey('passwordField'),
                            controller: _password,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.only(left: 10, right: 10),
                              border: OutlineInputBorder(
                                  borderSide: const BorderSide(style: BorderStyle.none),
                                  borderRadius: const BorderRadius.all(Radius.circular(6.0))),
                              hintText: 'password',
                              hintStyle: TextStyle(fontWeight: FontWeight.w300),
                              suffixIcon: TextButton(
                                onPressed: _toggle,
                                style: ButtonStyle(alignment: Alignment.centerRight),
                                child: Icon(_hidePassword ? Icons.lock : Icons.lock_open,
                                    color: CupertinoColors.inactiveGray),
                              ),
                            ),
                            obscureText: _hidePassword,
                            keyboardType: TextInputType.visiblePassword,
                            style: style.copyWith(color: Colors.black),
                            validator: (_password) {
                              if (_password == null || _password.isEmpty) return 'Enter password';
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
                          child: ElevatedButton(
                            key: const ValueKey('signInButton'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[400]),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (await ConnectivityWrapper.instance.isConnected) {
                                  var result =
                                      await authService.signInWithFirebase(_email.text.trim(), _password.text.trim());
                                  if (result.runtimeType == FirebaseAuthException) {
                                    _showLoginFailure(context, result.code, result.message);
                                  }
                                } else {
                                  var result =
                                      await authService.signInWithHive(_email.text.trim(), _password.text.trim());
                                  if (result.runtimeType == Exception) {
                                    _showLoginFailure(context, result.message, result.details);
                                  }
                                }
                              }
                            },
                            child: Text(
                              "Sign In",
                              style: style.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        TextButton(
                          key: const ValueKey('createAccountButton'),
                            child: Text('Create New Account', style: style.copyWith(color: Colors.white, fontSize: 14)),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignUpPage()));
                            }),
                        Text('Version: Beta 0.1.4',
                            style: TextStyle(color: Colors.white54, fontSize: 12), textAlign: TextAlign.center),
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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<bool> _showLoginFailure(BuildContext context, dynamic message, dynamic details) {
    showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog.adaptive(
            title: Text(message),
            content: details != null ? Text(details) : null,
            actions: [
              TextButton(
                style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
                child: Text('Okay'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
    return new Future.value(false);
  }
}
