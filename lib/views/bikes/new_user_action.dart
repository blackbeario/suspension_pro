import 'package:flutter/material.dart';
import 'package:suspension_pro/features/purchases/presentation/screens/buy_credits.dart';
import 'package:suspension_pro/views/profile/profile.dart';

class NewUserAction extends StatelessWidget {
  NewUserAction({Key? key, required this.title, required this.icon, required this.screen, this.complete})
      : super(key: key);

  final String title;
  final Icon icon;
  final Widget screen;
  final bool? complete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: icon,
        tileColor: complete != null && complete! ? Colors.green.shade50 : Colors.amber.shade50,
        title: Text(title),
        trailing: Icon(Icons.check_circle,
            size: 30, color: complete != null && complete! ? Colors.green : Colors.grey.withValues(alpha: 0.10)),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) {
              return screen.runtimeType == Profile || screen.runtimeType == BuyCredits ? screen :
               Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: AppBar(title: Text(title), actions: null),
                body: screen,
              );
            })),
      ),
    );
  }
}
