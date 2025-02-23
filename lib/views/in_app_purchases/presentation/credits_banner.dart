import 'package:flutter/material.dart';
import 'package:suspension_pro/views/in_app_purchases/in_app_bloc.dart';

class CreditsBanner extends StatefulWidget {
  const CreditsBanner({Key? key}) : super(key: key);

  @override
  State<CreditsBanner> createState() => _CreditsBannerState();
}

class _CreditsBannerState extends State<CreditsBanner> {
  final InAppBloc _inAppBloc = InAppBloc();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _inAppBloc,
      builder: (context, _) {
        String count = _inAppBloc.freeCredits.toString();
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListTile(
            dense: true,
            leading: Icon(Icons.warning_amber, color: Colors.amber, size: 36),
            title: Text('You may generate 3 free AI suggestions. Afterwards, you must purchase an AI Pack. You have $count free credits remaining.', style: TextStyle(color: Colors.black54)),
            tileColor: Colors.amber.shade50,
          )
        );
      },
    );
  }
}
