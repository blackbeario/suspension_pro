import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    required this.color,
    required this.imagePath,
    required this.subtitle,
    required this.title,
    this.titleColor,
    this.subtitleColor,
  });

  final Color? color, titleColor, subtitleColor;
  final String title, subtitle, imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (imagePath.isNotEmpty)
            Stack(
              children: [
                ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.transparent],
                    ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    height: 500,
                  ),
                ),
              ],
            ),
          Container(
            margin: EdgeInsets.only(left: 2, right: 2),
            height: 280,
            padding: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                color: Colors.white10, 
                gradient: LinearGradient(colors: [Colors.white60, Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter), 
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Text(
                    subtitle,
                    style: TextStyle(color: subtitleColor),
                    textAlign: TextAlign.justify,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
