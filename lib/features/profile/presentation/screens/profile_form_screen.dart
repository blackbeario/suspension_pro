import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/auth/domain/user_notifier.dart';
import 'package:ridemetrx/core/providers/service_providers.dart';
import 'package:ridemetrx/features/profile/presentation/widgets/profile_pic.dart';

class ProfileFormScreen extends ConsumerStatefulWidget {
  const ProfileFormScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userNotifierProvider);
    _usernameController = TextEditingController(text: user.userName);
    _firstNameController = TextEditingController(text: user.firstName);
    _lastNameController = TextEditingController(text: user.lastName);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    final user = ref.read(userNotifierProvider);
    final db = ref.read(databaseServiceProvider);

    // Update UserNotifier state
    ref.read(userNotifierProvider.notifier).updateProfile(
      userName: _usernameController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
    );

    // Update Firebase
    await db.updateUser(
      _usernameController.text,
      _firstNameController.text,
      _lastNameController.text,
      user.email,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await _updateUser();
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
        title: const Text('Edit Profile'),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please add a username';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  isDense: true,
                  helperText: 'Your preferred username',
                  filled: true,
                  hoverColor: Colors.blue,
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'First name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          helperText: 'First name',
                          filled: true,
                          hoverColor: Colors.blue.shade100,
                          border: const OutlineInputBorder(),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Last name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          helperText: 'Last name',
                          filled: true,
                          hoverColor: Colors.blue.shade100,
                          border: const OutlineInputBorder(),
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
