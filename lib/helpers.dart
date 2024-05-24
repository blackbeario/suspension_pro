import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

loadURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $uri');
  }
}

dynamic getEnv(String key, {dynamic defaultValue}) {
  if (!dotenv.env.containsKey(key) && defaultValue != null) {
    return defaultValue;
  }
  String? value = dotenv.env[key];
  if (value == 'null' || value == null) {
    return null;
  }
  if (value.toLowerCase() == 'true') {
    return true;
  }
  if (value.toLowerCase() == 'false') {
    return false;
  }
  return value.toString();
}