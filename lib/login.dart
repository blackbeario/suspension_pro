import 'package:flutter/material.dart';
import 'package:suspension_pro/signup.dart';
// import 'package:suspension_pro/signup.dart';
import './services/auth_service.dart'; // iOS
import 'package:flutter/cupertino.dart';
// ignore: implementation_imports
import 'package:provider/src/provider.dart';

class LoginPage extends StatefulWidget {
  createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _hidePassword = true;
  String animationName = 'flash';

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
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
    return CupertinoPageScaffold(
      backgroundColor: Color.fromRGBO(50, 39, 116, 100),
      key: _key,
      child: Container(
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/josh_lower_hareball.jpg'),
                alignment: Alignment.center,
                fit: BoxFit.fitHeight)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: Text('Suspension Pro',
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
                  )),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
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
                  textAlign: TextAlign.center),
            ),
            SafeArea(
              child: Form(
                key: _formKey,
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CupertinoTextField(
                          controller: _email,
                          padding: EdgeInsets.all(10.0),
                          // validator: (value) =>
                          // (value.isEmpty) ? "Please Enter Email" : null,
                          placeholder: "email",
                          style: style.copyWith(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CupertinoTextField(
                          padding: EdgeInsets.all(10.0),
                          controller: _password,
                          placeholder: "password",
                          obscureText: _hidePassword,
                          // style: TextStyle(color: CupertinoColors.white),
                          style: style.copyWith(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          suffix: TextButton(
                              onPressed: _toggle,
                              child: Icon(
                                  _hidePassword ? Icons.lock : Icons.lock_open,
                                  color: CupertinoColors.inactiveGray)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 8.0),
                        child: Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.orange[400],
                          child: CupertinoButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await authService.signIn(
                                    _email.text.trim(), _password.text.trim());
                              }
                            },
                            child: Text(
                              "Sign In",
                              style: style.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        child: Text('Create New Account'),
                        onPressed: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              fullscreenDialog: true,
                              builder: (context) {
                              // Return the settings detail form screen. 
                              return SignUpPage();
                            })
                          );
                      }
                      ),
                      Text('Version: Beta 0.1.4',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                          textAlign: TextAlign.center),
                    ],
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
}
