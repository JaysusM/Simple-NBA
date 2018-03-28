import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/animation.dart';

class loadingAnimation extends StatefulWidget {
  @override
  State createState() => new loadingAnimationState();
}

class loadingAnimationState extends State with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> angleAnimation;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(duration: new Duration(milliseconds: 1500), vsync: this);

    angleAnimation = new CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    angleAnimation = new Tween(begin: 0.0, end: 360.0).animate(controller)
      ..addListener(() {
        this.setState(() {});
      });

    angleAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
          controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
          controller.forward();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Transform.rotate(
            angle: angleAnimation.value / 360 * 2 * PI,
            child: new Center(child: new Container(
              decoration: new BoxDecoration(image: new DecorationImage(image: new AssetImage("assets/logo.png")))
              ,padding: new EdgeInsets.all(100.0),
            ))));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}