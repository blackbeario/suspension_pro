import 'package:flutter/material.dart';
import 'package:ridemetrx/features/profile/presentation/widgets/roadmap/app_roadmap_item.dart';
import 'package:ridemetrx/features/profile/presentation/widgets/roadmap/suggestion_box.dart';

class AppRoadmap extends StatelessWidget {
  AppRoadmap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text('App Roadmap')),
      body: Material(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 16),
              Text('Features currently in development', style: TextStyle(fontSize: 16)),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppRoadmapItem(
                        icon: Icons.check_circle_outline, color: Colors.green, value: 'Offine-first architecture'),
                    AppRoadmapItem(
                        icon: Icons.check_circle_outline, color: Colors.green, value: 'Populate data from local db'),
                    AppRoadmapItem(icon: Icons.check_circle_outline, color: Colors.green, value: 'Clone bike settings'),
                    AppRoadmapItem(icon: Icons.check_circle_outline, color: Colors.green, value: 'Free Community Settings Browser'),
                    AppRoadmapItem(icon: Icons.check_circle_outline, color: Colors.green, value: 'Pro Community Settings Browser'),
                    AppRoadmapItem(icon: Icons.check_circle_outline, color: Colors.green, value: 'User app settings screen'),
                    AppRoadmapItem(icon: Icons.circle_outlined, value: 'Suspension products database'),
                    AppRoadmapItem(icon: Icons.circle_outlined, value: 'Heatmap integration for rides'),
                    AppRoadmapItem(icon: Icons.circle_outlined, value: 'Enhanced ride analytics'),
                    AppRoadmapItem(icon: Icons.circle_outlined, value: 'Push notifications'),
                    AppRoadmapItem(icon: Icons.circle_outlined, value: 'Custom theme options'),
                  ],
                ),
              ),
              SuggestionBox(),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
