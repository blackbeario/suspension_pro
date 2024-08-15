import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:suspension_pro/models/user.dart';
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

Future share(context, AppUser myUser, String setting, fork, forkSettings, shock, shockSettings, frontTire, rearTire) async {
    late String text;
    if (shock != null) {
      text =
          "Suspension Pro '$setting' shared by ${myUser.username} \n\n${fork['year'] + ' ' + fork['brand'] + ' ' + fork['model']} Fork Settings: \n$forkSettings, \n\n${shock['year'] + ' ' + shock['brand'] + ' ' + shock['model']} Shock Settings: \n$shockSettings, \n\nFront Tire: \n$frontTire, /n/nRear Tire: \n$rearTire \n\nGet the Suspension Pro App for iOS soon on the Apple AppStore!";
    } else {
      text =
          "Suspension Pro '$setting' shared by ${myUser.username} \n\n${fork['year'] + ' ' + fork['brand'] + ' ' + fork['model']} Fork Settings: \n$forkSettings, \n\nFront Tire: \n$frontTire, /n/nRear Tire: \n$rearTire \n\nGet the Suspension Pro App for iOS soon on the Apple AppStore!";
    }
    Share.share(text, subject: setting);
    await _addSharePoints(myUser, 1);
  }

  _addSharePoints(AppUser myUser, int value) {
    // Not updated since we're passing in the user. Need to get user from a stream.
    int? currentPoints = myUser.points ?? 0;
    String role = myUser.role!;
    db.addSharePoints(myUser.id, currentPoints, role);
  }