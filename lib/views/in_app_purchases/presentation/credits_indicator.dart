import 'package:flutter/material.dart';
import 'package:suspension_pro/views/in_app_purchases/in_app_bloc.dart';

class CreditsIndicator extends StatefulWidget {
  const CreditsIndicator({Key? key}) : super(key: key);

  @override
  State<CreditsIndicator> createState() => _CreditsIndicatorState();
}

class _CreditsIndicatorState extends State<CreditsIndicator> {
  final InAppBloc _inAppBloc = InAppBloc();

  _setIndicatorColor(int credits) {
    if (credits < 10) return Colors.redAccent;
    if (credits <= 20 && credits > 10) return Colors.amber;
    if (credits > 20) return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _inAppBloc,
      builder: (context, _) {
        final String credits = _inAppBloc.credits.toString();
        return Container(
          alignment: Alignment.center,
          height: 18,
          width: 18,
          decoration: BoxDecoration(
              color: _setIndicatorColor(_inAppBloc.credits), shape: BoxShape.circle),
          child: Text(credits, style: TextStyle(color: Colors.white)),
        );
      },
    );
  }
}
