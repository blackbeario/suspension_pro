import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfo extends StatefulWidget {
  const AppInfo({Key? key}) : super(key: key);

  @override
  State<AppInfo> createState() => _AppInfoState();
}

class _AppInfoState extends State<AppInfo> {
  final _formKey = GlobalKey<FormState>();
  final _suggestionController = TextEditingController();
  bool formSubmitted = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 5),
        middle: Text('Version 0.1.4'),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Material(
          color: Colors.white,
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text('Privacy Policy'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => _loadURL('https://vibesoftware.io/privacy/suspension_pro'),
              ),
              ListTile(
                title: Text('Terms & Conditions'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => _loadURL('https://vibesoftware.io/terms/suspension_pro'),
              ),
              ListTile(
                title: Text('App Roadmap (2024)'),
                subtitle: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SizedBox(height: 4),
                      AppRoadmapItem(value: 'Offline Support (May)'),
                      AppRoadmapItem(value: 'Create database for importing suspension products dynamically (June)'),
                      AppRoadmapItem(value: 'Additional support for less common suspension products (June)'),
                      AppRoadmapItem(value: 'Custom user app backgrounds (July)'),
                      AppRoadmapItem(value: 'Flush out user points rewards (TBD)'),
                      AppRoadmapItem(value: 'ChatGPT suspension suggestions based on bike model and rider weight (TBD)'),
                      AppRoadmapItem(value: 'Maybe some fancy animations of the shock dials when a user inputs settings (TBD)'),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: Text('Suggestion Box'),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            hintText: 'Suggestions for this app? Let us know!',
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
              )
            ],
          ),
        ),
      ),
    );
  }

  _loadURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
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

class AppRoadmapItem extends StatelessWidget {
  const AppRoadmapItem({Key? key, required this.value}) : super(key: key);
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: Text('* $value'),
    );
  }
}
