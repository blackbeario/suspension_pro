import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:suspension_pro/services/db_service.dart';
import 'package:url_launcher/url_launcher.dart';

final db = DatabaseService();

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

Future share(context, String username, String setting, fork, forkSettings, shock, shockSettings, frontTire,
    rearTire) async {
  late String text;

  if (shock != null) {
    text =
        "Suspension Pro '$setting' shared by ${username} \n\n${fork['year'] + ' ' + fork['brand'] + ' ' + fork['model']} Fork Settings: \n$forkSettings, \n\n${shock['year'] + ' ' + shock['brand'] + ' ' + shock['model']} Shock Settings: \n$shockSettings, \n\nFront Tire: \n$frontTire, /n/nRear Tire: \n$rearTire \n\nGet the Suspension Pro App for iOS soon on the Apple AppStore!";
  } else {
    text =
        "Suspension Pro '$setting' shared by ${username} \n\n${fork['year'] + ' ' + fork['brand'] + ' ' + fork['model']} Fork Settings: \n$forkSettings, \n\nFront Tire: \n$frontTire, /n/nRear Tire: \n$rearTire \n\nGet the Suspension Pro App for iOS soon on the Apple AppStore!";
  }
  await Share.share(text, subject: setting);
  // await db.addSharePoints(role);
}
