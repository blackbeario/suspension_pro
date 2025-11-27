import 'package:flutter/material.dart';
import 'package:ridemetrx/features/profile/presentation/screens/profile_screen.dart';

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
              return screen.runtimeType == ProfileScreen ? screen :
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
