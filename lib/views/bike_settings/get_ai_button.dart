import 'package:flutter/material.dart';
import 'package:suspension_pro/core/models/bike.dart';
import 'package:suspension_pro/main.dart';
import 'package:suspension_pro/views/forms/openai_form.dart';

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
            child: Text('Get AI Suggestion'),
            onPressed: () {
              print(MyApp.myTabbedPageKey.currentState!.tabController.index);
              // Navigator.of(context).push(MaterialPageRoute(builder: (context) => OpenAiRequest(selectedBike: bike)));
            },
            // onPressed: () => pushScreen(context, 'Add Setting', null, OpenAiRequest(selectedBike: bike), true),
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
