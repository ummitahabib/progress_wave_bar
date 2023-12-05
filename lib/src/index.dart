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
        Radius.circular(0),
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
        Radius.circular(0),
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
        Radius.circular(0),
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
        Radius.circular(0),
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
        Radius.circular(0),
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

  WaveProgressBar({
    this.isVerticallyAnimated = true,
    this.isHorizontallyAnimated = true,
    required this.listOfHeights,
    this.initalColor = Colors.red,
    this.progressColor = Colors.green,
    this.backgroundColor = Colors.white,
    required this.width,
    required this.progressPercentage,
    this.timeInMilliSeconds = 20000,
  });

  @override
  WaveProgressBarState createState() {
    return WaveProgressBarState();
  }
}

class WaveProgressBarState extends State<WaveProgressBar>
    with SingleTickerProviderStateMixin {
  late Animation<double> horizontalAnimation;
  late Animation<double> verticalAnimation;
  late AnimationController controller;
  late double begin;
  late double end;

  @override
  void initState() {
    begin = 0;
    end = widget.width;

    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: widget.timeInMilliSeconds),
      vsync: this,
    );

    horizontalAnimation = Tween(begin: begin, end: end).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> arrayOfBars = <Widget>[];
    arrayOfBars.add(
      CustomPaint(
        painter: BackgroundBarPainter(
          widthOfContainer: (widget.isHorizontallyAnimated)
              ? horizontalAnimation.value
              : widget.width,
          heightOfContainer: widget.listOfHeights.reduce(max),
          progressPercentage: widget.progressPercentage,
          initialColor: widget.initalColor,
          progressColor: widget.progressColor,
        ),
      ),
    );

    for (int i = 0; i < widget.listOfHeights.length; i++) {
      verticalAnimation =
          Tween(begin: 0.0, end: widget.listOfHeights[i]).animate(controller)
            ..addListener(() {
              setState(() {});
            });
      controller.forward();
      arrayOfBars.add(
        CustomPaint(
          painter: SingleBarPainter(
            startingPosition:
                (i * (widget.width / widget.listOfHeights.length)),
            singleBarWidth: widget.width / widget.listOfHeights.length,
            maxSeekBarHeight: widget.listOfHeights.reduce(max) + 1,
            actualSeekBarHeight: (widget.isVerticallyAnimated)
                ? verticalAnimation.value
                : widget.listOfHeights[i],
            heightOfContainer: widget.listOfHeights.reduce(max),
            backgroundColor: widget.backgroundColor,
          ),
        ),
      );
    }

    return Center(
      child: Container(
        height: widget.listOfHeights.reduce(max),
        width: widget.width,
        child: Row(
          children: arrayOfBars,
        ),
      ),
    );
  }
}
