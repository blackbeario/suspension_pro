import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SuggestionBox extends StatefulWidget {
  const SuggestionBox({Key? key}) : super(key: key);

  @override
  State<SuggestionBox> createState() => _SuggestionBoxState();
}

class _SuggestionBoxState extends State<SuggestionBox> {
  final _formKey = GlobalKey<FormState>();
  final _suggestionController = TextEditingController();
  bool formSubmitted = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Suggestion Box'),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                autofocus: false,
                onChanged: (value) => setState(() {}),
                maxLines: 5,
                minLines: 1,
                decoration: InputDecoration(
                  helperText: formSubmitted ? 'Thanks!' : null,
                  contentPadding: EdgeInsets.all(6),
                  filled: true,
                  border: OutlineInputBorder(),
                  hintText: 'Ideas for this app? Let us know!',
                ),
                style: TextStyle(fontSize: 12, overflow: TextOverflow.fade),
                controller: _suggestionController,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 20),
              CupertinoButton(
                disabledColor: CupertinoColors.inactiveGray,
                color: CupertinoColors.activeBlue,
                child: Text('Submit', style: TextStyle(color: Colors.white)),
                onPressed: _suggestionController.text.isNotEmpty ? () => _submitSuggestion(_suggestionController.text) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries.map((MapEntry<String, String> e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
  }

  _submitSuggestion(String message) async {
    final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'support@vibesoftware.io',
        query: encodeQueryParameters(<String, String>{
          'subject': message,
        }));
    if (await canLaunchUrl(emailLaunchUri)) {
      bool result = await launchUrl(emailLaunchUri);
      if (result) {
        setState(() {
          formSubmitted = true;
          _suggestionController.clear();
        });
      }
    } else {
      throw Exception('Could not launch $emailLaunchUri');
    }
  }
}
