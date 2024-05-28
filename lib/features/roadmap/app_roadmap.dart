import 'package:flutter/material.dart';
import 'package:suspension_pro/features/roadmap/app_roadmap_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:suspension_pro/features/roadmap/suggestion_box.dart';

class AppRoadmap extends StatelessWidget {
  AppRoadmap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        middle: Text('App Roadmap'),
      ),
      child: Material(
        color: Colors.white,
        child: ListView(
          children: [
            ListTile(
              title: Text('List of projected plans for this app'),
              subtitle: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppRoadmapItem(value: 'Offline Support (May)'),
                    AppRoadmapItem(value: 'ChatGPT suspension suggestions based on bike model and rider weight (May)'),
                    AppRoadmapItem(value: 'Create database for importing suspension products dynamically (June)'),
                    AppRoadmapItem(value: 'Additional support for less common suspension products (June)'),
                    AppRoadmapItem(value: 'Custom user app backgrounds (July)'),
                    AppRoadmapItem(value: 'Flush out user points rewards (TBD)'),
                    AppRoadmapItem(value: 'Animations of the fork/shock dials when a user inputs settings (TBD)'),
                  ],
                ),
              ),
            ),
            SuggestionBox()
          ],
        ),
      ),
    );
  }
}
