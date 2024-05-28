import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:provider/src/provider.dart';
import './services/auth_service.dart';
import 'package:flutter/cupertino.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextStyle style = TextStyle(fontSize: 20.0);
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;

  void _toggle() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/cupcake.jpg"),
              alignment: Alignment.topCenter,
              fit: BoxFit.fitHeight),
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
                    controller: emailController,
                    padding: EdgeInsets.all(10.0),
                    placeholder: "email",
                    style: style.copyWith(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CupertinoTextField(
                    padding: EdgeInsets.all(10.0),
                    controller: passwordController,
                    placeholder: "password",
                    obscureText: _hidePassword,
                    style: style.copyWith(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    suffix: TextButton(
                        onPressed: _toggle,
                        child: Icon(
                            _hidePassword ? Icons.lock : Icons.lock_open,
                            color: CupertinoColors.inactiveGray)),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 0.0),
                  child: Material(
                    elevation: 1.0,
                    borderRadius: BorderRadius.circular(8.0),
                    color: CupertinoColors.activeBlue,
                    child: CupertinoButton(
                      onPressed: () {
                        authService
                            .createUser(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            )
                            .then((authResult) => {
                                  if (authResult.id != null)
                                    {
                                      authService.createUserData(authResult.id, authResult.email),
                                      Navigator.pop(context)
                                    }
                                  else
                                    {_showSignUpErrors(context, authResult)}
                                });
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showSignUpErrors(BuildContext context, String authResult) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(authResult),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: Text('Okay'),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context, 'Discard');
                  }),
            ],
          );
        });
    return Future.value(false);
  }
}
