import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

loadURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $uri');
  }
}

dynamic getEnv(String key, {dynamic defaultValue}) {
  if (!dotenv.env.containsKey(key) && defaultValue != null) () => defaultValue;
  String? value = dotenv.env[key];
  if (value == 'null' || value == null) {
    return null;
  }
  if (value.toLowerCase() == 'true') () => true;
  if (value.toLowerCase() == 'false') () => false;
  return value.toString();
}

// Old email/text share function removed - will be replaced with Community sharing
// TODO: Implement community sharing feature

void pushScreen(BuildContext context, String title, List<Widget>? actions, Widget form, bool isFullscreen) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
        fullscreenDialog: isFullscreen,
        builder: (context) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(title: Text(title), actions: actions),
            body: form,
          );
        }),
  );
}
