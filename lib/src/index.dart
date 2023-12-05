import 'dart:math';

import 'package:flutter/material.dart';

class BackgroundBarPainter extends CustomPainter {
  final double widthOfContainer;
  final double heightOfContainer;
  final double progressPercentage;
  final Color initialColor;
  final Color progressColor;
  final Paint trackPaint;
  final Paint progressPaint;

  BackgroundBarPainter({
    required this.widthOfContainer,
    required this.heightOfContainer,
    required this.initialColor,
    required this.progressColor,
    required this.progressPercentage,
  })  : trackPaint = Paint()
          ..color = initialColor
          ..style = PaintingStyle.fill,
        progressPaint = Paint()
          ..color = progressColor
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          0,
          -heightOfContainer / 2,
          widthOfContainer,
          heightOfContainer,
        ),
        const Radius.circular(0),
      ),
      trackPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          0,
          -heightOfContainer / 2,
          (progressPercentage * widthOfContainer) / 100,
          heightOfContainer,
        ),
        const Radius.circular(0),
      ),
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class SingleBarPainter extends CustomPainter {
  static Color barColor = Colors.transparent;
  final Color backgroundColor;
  final double singleBarWidth;
  final double barBorderRadius;
  final Paint trackPaint;
  final Paint aboveAndBelowPaint;
  final double maxSeekBarHeight;
  final double actualSeekBarHeight;
  final double startingPosition;
  final double heightOfContainer;

  SingleBarPainter({
    required this.backgroundColor,
    this.barBorderRadius = 0,
    required this.singleBarWidth,
    required this.maxSeekBarHeight,
    required this.actualSeekBarHeight,
    required this.heightOfContainer,
    required this.startingPosition,
  })  : trackPaint = Paint()
          ..color = barColor
          ..style = PaintingStyle.fill,
        aboveAndBelowPaint = Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final double outerSideHeight = maxSeekBarHeight - actualSeekBarHeight;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          startingPosition,
          -heightOfContainer / 1.9,
          singleBarWidth,
          outerSideHeight / 2,
        ),
        const Radius.circular(0),
      ),
      aboveAndBelowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          startingPosition,
          outerSideHeight / 2 - heightOfContainer / 2,
          singleBarWidth,
          actualSeekBarHeight,
        ),
        Radius.circular(barBorderRadius),
      ),
      trackPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          startingPosition,
          (outerSideHeight / 2) - heightOfContainer / 2 + actualSeekBarHeight,
          singleBarWidth,
          outerSideHeight / 2,
        ),
        const Radius.circular(0),
      ),
      aboveAndBelowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          startingPosition,
          -heightOfContainer / 2,
          0.2 * singleBarWidth,
          heightOfContainer,
        ),
        const Radius.circular(0),
      ),
      aboveAndBelowPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class WaveProgressBar extends StatefulWidget {
  final double progressPercentage;
  final List<double> listOfHeights;
  final double width;
  final Color initalColor;
  final Color progressColor;
  final Color backgroundColor;
  final int timeInMilliSeconds;
  final bool isVerticallyAnimated;
  final bool isHorizontallyAnimated;

  const WaveProgressBar({
    super.key,
    this.isVerticallyAnimated = true,
    this.isHorizontallyAnimated = true,
    required this.listOfHeights,
    this.initalColor = Colors.red,
    this.progressColor = Colors.green,
    this.backgroundColor = Colors.white,
    required this.width,
    required this.progressPercentage,
    this.timeInMilliSeconds = 2000,
  });

  @override
  _WaveProgressBarState createState() => _WaveProgressBarState();
}

class _WaveProgressBarState extends State<WaveProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: widget.timeInMilliSeconds),
      vsync: this,
    );
    controller.repeat(); // Loops the animation

    // Add listeners to update the UI when the animation value changes
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose(); // Dispose of the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WaveProgressPainter(
        progressPercentage: widget.progressPercentage,
        listOfHeights: widget.listOfHeights,
        width: widget.width,
        initialColor: widget.initalColor,
        progressColor: widget.progressColor,
        backgroundColor: widget.backgroundColor,
        animationController: controller,
      ),
    );
  }
}

class WaveProgressPainter extends CustomPainter {
  final double progressPercentage;
  final List<double> listOfHeights;
  final double width;
  final Color initialColor;
  final Color progressColor;
  final Color backgroundColor;
  final AnimationController animationController;

  WaveProgressPainter({
    required this.progressPercentage,
    required this.listOfHeights,
    required this.width,
    required this.initialColor,
    required this.progressColor,
    required this.backgroundColor,
    required this.animationController,
  }) : super(repaint: animationController);

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate the current width based on progressPercentage and animation value
    double currentWidth = (progressPercentage * width) / 100;
    double animationValue = animationController.value * currentWidth;

    // Drawing the animated rectangle
    Paint backgroundPaint = Paint()..color = backgroundColor;
    Paint progressPaint = Paint()..color = progressColor;

    // Draw background
    canvas.drawRect(Rect.fromLTWH(0, 0, width, size.height), backgroundPaint);

    // Draw progress bar
    canvas.drawRect(
      Rect.fromLTWH(0, 0, animationValue, size.height),
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(WaveProgressPainter oldDelegate) {
    return false;
  }
}
