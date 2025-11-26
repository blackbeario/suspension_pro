import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike.dart';

class GetAiButton extends StatelessWidget {
  const GetAiButton({
    Key? key,
    required this.bike,
  }) : super(key: key);

  final Bike bike;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topEnd,
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            child: Text('AI Suggestions'),
            onPressed: () {
              // Navigate to AI tab using go_router
              context.go('/ai');
              // TODO: Need to pass bike data to AI page - will implement with state management
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.black87,
              fixedSize: Size(240, 50),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black54,
          ),
          child: Icon(
            Icons.lock,
            color: Colors.amber,
            size: 18.0,
          ),
        ),
      ],
    );
  }
}
