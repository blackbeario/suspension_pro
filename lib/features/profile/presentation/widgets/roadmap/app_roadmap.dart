import 'package:flutter/material.dart';
import 'package:suspension_pro/features/profile/presentation/widgets/roadmap/app_roadmap_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:suspension_pro/features/profile/presentation/widgets/roadmap/suggestion_box.dart';

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
              title: Text('List of app plans'),
              subtitle: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppRoadmapItem(value: 'Populate settings from HIVE'),
                    AppRoadmapItem(value: 'Implement workmanager plugin for backround sync'),
                    AppRoadmapItem(value: 'Set bool flag for synced data. If remote sync fails set flag to false and try workmanager method'),
                    AppRoadmapItem(value: 'Import suspension products dynamically'),
                    AppRoadmapItem(value: 'Support for less common suspension products'),
                    AppRoadmapItem(value: 'Custom theme options'),
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
