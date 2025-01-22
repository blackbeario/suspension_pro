import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:suspension_pro/views/onboarding/onboarding_page.dart';
import 'package:suspension_pro/main.dart';

class Onboarding extends StatefulWidget {
  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final pageController = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Container(
          padding: EdgeInsets.only(bottom: 60),
          child: PageView(
            controller: pageController,
            onPageChanged: (index) {
              setState(() => isLastPage = index == 3);
            },
            children: [
              OnboardingPage(
                color: Colors.grey.shade900,
                title: 'Unlimited Bikes',
                titleColor: Colors.blue.shade200,
                subtitleColor: Colors.white,
                subtitle:
                    'Add as many bikes as you want, whether you have just one or a fleet. Keep ride settings for your trail bike, e-bike, DH rig, kids bikes, and more. Great for bike/suspension shops who need to keep up with many customers. Also keep track of those important serial numbers and personal notes like tire choices.',
                imagePath: 'assets/manybikes.jpg',
      
              ),
              OnboardingPage(
                color: Colors.grey.shade900,
                title: 'Unlimited Settings',
                subtitle:
                    'Save base settings for your ride, then create settings for that trail that requires specific damping. If you\'re a racer who travels a lot, keep records for each course and always have them handy. No more need for paper or finding them in your notes app.',
                imagePath: 'assets/grip2.jpg',
                titleColor: Colors.orange.shade300,
                subtitleColor: Colors.white,
              ),
              OnboardingPage(
                color: Colors.grey.shade900,
                titleColor: Colors.amber.shade300,
                subtitleColor: Colors.white,
                title: 'Share Your Settings',
                subtitle:
                    'Got it dialed? Share with your mates! Easily send your ride settings to your friends so they can import them. You can even rack up points for sharing, which gives you future access to unlock features.',
                imagePath: 'assets/mtbphone.jpg',
              ),
              OnboardingPage(
                color: Colors.grey.shade900,
                title: 'Generate Settings',
                subtitle: 'Get suspension suggestions from AI based on bike, suspension components, rider weight and trail conditions. If you like the response, save it directly to your settings for that bike.',
                imagePath: 'assets/openai.jpg',
                titleColor: Colors.teal,
                subtitleColor: Colors.white,
              ),
            ],
          ),
        ),
        bottomSheet: isLastPage
            ? Container(
                alignment: Alignment.topCenter,
                color: Colors.teal,
                width: double.infinity,
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setBool('showHome', true);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AuthenticationWrapper()));
                      },
                      child: Text('Get Started!', style: TextStyle(fontSize: 24, color: Colors.white))),
                ),
              )
            : Container(
                width: double.infinity,
                height: 80,
                color: Colors.grey.shade900,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 32),
                      child: TextButton(
                        onPressed: () => pageController.jumpToPage(3),
                        child: Text('SKIP', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: SmoothPageIndicator(
                        controller: pageController,
                        count: 4,
                        effect: WormEffect(
                          spacing: 16,
                          dotColor: Colors.white24,
                          activeDotColor: Colors.amber,
                        ),
                        onDotClicked: (index) => pageController.animateToPage(
                          index,
                          curve: Curves.easeIn,
                          duration: Duration(milliseconds: 500),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 32),
                      child: TextButton(
                        onPressed: () => pageController.nextPage(curve: Curves.easeInOut, duration: Duration(milliseconds: 500)),
                        child: Text('NEXT', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
