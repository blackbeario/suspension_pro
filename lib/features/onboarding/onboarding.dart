import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboarding extends StatefulWidget {
  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(bottom: 80),
        child: PageView(
        controller: pageController,
          children: [
            Container(
              color: Colors.blue,
              child: Center(
                child: Text('Add Bikes'),
              ),
            ),
            Container(
              color: Colors.indigo,
              child: Center(
                child: Text('Add Settings'),
              ),
            ),
            Container(
              color: Colors.amber,
              child: Center(
                child: Text('Get AI Suggestions'),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        height: 80,
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 32),
              child: TextButton(
                onPressed: () => pageController.jumpToPage(2),
                child: Text('SKIP'),
              ),
            ),
            Center(child: SmoothPageIndicator(
              controller: pageController,
              count: 3,
              // effect: WormEffect(
              //   spacing: 16,
              //   dotColor: Colors.black26,
              //   activeDotColor: Colors.amber,
              // ),
              onDotClicked: (index) => pageController.animateToPage(
                index,
                curve: Curves.easeIn,
                duration: Duration(milliseconds: 500),
              ),
            ),),
            Padding(
              padding: EdgeInsets.only(right: 32),
              child: TextButton(
                onPressed: () => pageController.nextPage(
                  curve: Curves.easeInOut,
                  duration: Duration(milliseconds: 500)
                ),
                child: Text('NEXT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
