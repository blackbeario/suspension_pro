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
              SizedBox(height: 20),
              Text('Upcoming Features', style: TextStyle(fontSize: 24)),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppRoadmapItem(
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                        value: 'Create offine-first architecture for remote locations'),
                    AppRoadmapItem(icon: Icons.check_circle_outline, color: Colors.green, value: 'Populate bike and settings data from Hive'),
                    AppRoadmapItem(
                        icon: Icons.circle_outlined, value: 'Community database of suspension setups for sharing & importing'),
                    AppRoadmapItem(icon: Icons.circle_outlined, value: 'Heatmaps for rough suspension setups'),
                    AppRoadmapItem(icon: Icons.circle_outlined, value: 'Import suspension products dynamically'),
                    AppRoadmapItem(icon: Icons.circle_outlined, value: 'Support for less common suspension products'),
                    AppRoadmapItem(icon: Icons.circle_outlined, value: 'Custom theme options'),
                  ],
                ),
              ),
              SuggestionBox()
            ],
          ),
        ),
      ),
    );
  }
}
