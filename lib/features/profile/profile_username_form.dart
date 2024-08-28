import 'package:flutter/material.dart';
import 'package:suspension_pro/models/user.dart';
import 'package:suspension_pro/services/db_service.dart';

class ProfileNameForm extends StatefulWidget {
  const ProfileNameForm({Key? key, required this.user}) : super(key: key);
  final AppUser user;

  @override
  State<ProfileNameForm> createState() => _ProfileNameFormState();
}

class _ProfileNameFormState extends State<ProfileNameForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.user.username ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<bool> _updateUser(uid, BuildContext context) {
    db.updateUser(_usernameController.text, widget.user.email!, widget.user.role!);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
    width: 270,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: TextFormField(
                autofocus: false,
                validator: (_usernameController) {
                  if (_usernameController == null || _usernameController.isEmpty) return 'Please add a username';
                  return null;
                },
                onEditingComplete: () {
                  if (_formKey.currentState!.validate()) {
                    _updateUser(widget.user.id, context);
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
                decoration: InputDecoration(
                  isDense: true,
                  helperText: 'Your preferred username',
                  filled: true,
                  hoverColor: Colors.blue.shade100,
                  border: OutlineInputBorder(),
                  hintText: 'username',
                ),
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                controller: _usernameController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
