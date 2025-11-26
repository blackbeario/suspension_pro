import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_plus/share_plus.dart';
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

Future share(BuildContext context, String bikeName, String username, String settingName, String? forkProduct, forkSettings,
    String? shockProduct, shockSettings, frontTire, rearTire) async {
  final String? forkString = forkProduct != null ? '\n\n$forkProduct, Fork Settings: \n$forkSettings,' : null;
  final String? shockString = shockProduct != null ? '\n\n$shockProduct Shock Settings: \n$shockSettings,' : null;
  final String appStoreString = '\n\nGet the RideMetrx App for iOS on the Apple AppStore!';
  final String body =
      "RideMetrx '$settingName' shared by ${username} $forkString $shockString \n\nFront Tire: \n$frontTire, /n/nRear Tire: \n$rearTire $appStoreString";

  await Share.share(body, subject: '$bikeName $settingName Setting');
  // await db.addSharePoints(role);
}

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
