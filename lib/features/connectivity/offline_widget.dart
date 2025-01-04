import 'package:flutter/material.dart';

class OfflineWidget extends StatefulWidget {
  const OfflineWidget();

  @override
  State<OfflineWidget> createState() => _OfflineWidgetState();
}

class _OfflineWidgetState extends State<OfflineWidget> {
  bool isShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => showOfflineMessage());
  }

  showOfflineMessage() async {
    if (mounted) {
      setState(() => isShown = !isShown);
      Future.delayed(const Duration(seconds: 5), () {
        setState(() => isShown = !isShown);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          top: 110,
          left: isShown ? 20 : -400,
          child: AnimatedContainer(
            height: 80,
            width: MediaQuery.of(context).size.width - 40,
            decoration: BoxDecoration(
              color: Colors.red.shade500,
              borderRadius: BorderRadius.circular(12)
            ),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                    onPressed: showSyncDialog,
                    icon: Icon(Icons.info_outline, color: Colors.white)),
                Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0, bottom: 4),
                      child: Text(
                        'Connection Offline',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Changes synced on reconnection',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )),
              ],
            ),
            duration: Duration(milliseconds: 300),
          ),
          duration: Duration(milliseconds: 300),
        ),
      ],
    );
  }

  void showSyncDialog() {
    showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: const Text('Offline Data Sync'),
          content: const Text(
            'Updates you make to your data\n'
            'are always saved locally first.\n'
            'When internet is available\n'
            'data is then synced remotely.',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
        );
  }
}
