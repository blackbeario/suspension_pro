import 'package:flutter/material.dart';
import 'package:suspension_pro/views/profile/profile_pic.dart';
import 'package:suspension_pro/core/models/user_singleton.dart';
import 'package:suspension_pro/core/services/db_service.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({Key? key}) : super(key: key);

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final UserSingleton _user = UserSingleton();
  final db = DatabaseService();


  @override
  void initState() {
    super.initState();
    _usernameController.text = _user.userName;
    _firstNameController.text = _user.firstName;
    _lastNameController.text = _user.lastName;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _updateUser() {
    UserSingleton().updateNewUser(_usernameController.text, _firstNameController.text, _lastNameController.text);
    db.updateUser(_usernameController.text, _firstNameController.text, _lastNameController.text, _user.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _updateUser();
                  Navigator.pop(context);
                }
              },
              child: Text('Save')),
        ],
        title: Text('Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProfilePicEditor(),
              TextFormField(
                validator: (_usernameController) {
                  if (_usernameController == null || _usernameController.isEmpty) return 'Please add a username';
                  return null;
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
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 4, 0),
                    child: SizedBox(
                      width: (MediaQuery.of(context).size.width / 2) - 24,
                      child: TextFormField(
                        validator: (_firstNameController) {
                          if (_firstNameController == null || _firstNameController.isEmpty) return 'First name';
                          return null;
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          helperText: 'First name',
                          filled: true,
                          hoverColor: Colors.blue.shade100,
                          border: OutlineInputBorder(),
                          hintText: 'first name',
                        ),
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        controller: _firstNameController,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 10, 0, 0),
                    child: SizedBox(
                      width: (MediaQuery.of(context).size.width / 2) - 24,
                      child: TextFormField(
                        validator: (_lastNameController) {
                          if (_lastNameController == null || _lastNameController.isEmpty) return 'Last name';
                          return null;
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          helperText: 'Last name',
                          filled: true,
                          hoverColor: Colors.blue.shade100,
                          border: OutlineInputBorder(),
                          hintText: 'last name',
                        ),
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        controller: _lastNameController,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
