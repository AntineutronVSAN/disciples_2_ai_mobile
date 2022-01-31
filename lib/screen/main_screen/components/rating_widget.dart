

import 'package:flutter/material.dart';

const maxContainerHeight = 100.0;
const int animatedContainerDurationMls = 200;
const Color activeRatingShapeColor = Colors.blue;
Color inactiveRatingShapeColor = Colors.blue.withOpacity(0.2);

const double ratingShapeWidth = 10.0;

const double ratingTextSize = 25.0;

class RatingWidget extends StatelessWidget {

  final double currentPositionRating;

  const RatingWidget({Key? key, required this.currentPositionRating}) : super(key: key);


  @override
  Widget build(BuildContext context) {


    var topContainerHeight = currentPositionRating >= 0.0
        ? maxContainerHeight * (currentPositionRating)
        : 1.0;
    var bottomContainerHeight = currentPositionRating < 0.0
        ? maxContainerHeight * (-currentPositionRating)
        : 1.0;

    if (topContainerHeight > maxContainerHeight) {
      topContainerHeight = maxContainerHeight;
    }

    if (bottomContainerHeight > maxContainerHeight) {
      bottomContainerHeight = maxContainerHeight;
    }

    final isTopContainer = topContainerHeight > bottomContainerHeight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          width: ratingShapeWidth,
          height: isTopContainer ? topContainerHeight : bottomContainerHeight,
          color: isTopContainer ? activeRatingShapeColor : inactiveRatingShapeColor,
          duration: const Duration(milliseconds: animatedContainerDurationMls),
        ),
        Text(
          currentPositionRating.toStringAsFixed(1),
          style: const TextStyle(
              fontSize: ratingTextSize, color: activeRatingShapeColor, fontWeight: FontWeight.bold),
        ),
        AnimatedContainer(
          width: ratingShapeWidth,
          height: isTopContainer ? topContainerHeight : bottomContainerHeight,
          color: !isTopContainer ? activeRatingShapeColor : inactiveRatingShapeColor,
          duration: const Duration(milliseconds: animatedContainerDurationMls),
        ),
      ],
    );
  }




}