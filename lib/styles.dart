import 'package:d2_ai_v2/theme/colors.dart';
import 'package:flutter/material.dart';

const double unitDescriptionParamsFontSize = 15.0;

class GameStyles {

  static TextStyle informationWhiteStyle() {
    return const TextStyle(
        fontSize: 12.0,
        color: Colors.white,
        );
  }

  static TextStyle getUnitShortDescriptionStyle() {
    return const TextStyle(
        fontSize: 12.0,
        color: UIColors.primary,
        fontWeight: FontWeight.bold);
  }

  static TextStyle getUnitDescriptionStyle() {
    return const TextStyle(
        fontSize: unitDescriptionParamsFontSize,
        color: UIColors.primary,
        fontWeight: FontWeight.bold);
  }
  static TextStyle getUnitDescriptionDebuffStyle() {
    return const TextStyle(
        fontSize: unitDescriptionParamsFontSize,
        color: Colors.deepPurple,
        fontWeight: FontWeight.bold);
  }

  static TextStyle getUnitShortDescriptionDebuffStyle() {
    return const TextStyle(
        fontSize: 12.0,
        color: Colors.deepPurple,
        fontWeight: FontWeight.bold);
  }

  static TextStyle getMainTextStyle() {
    return const TextStyle(
        fontSize: 12.0,
        color: UIColors.primary);
  }

  static TextStyle getMainAppBarTextStyle() {
    return const TextStyle(
        fontSize: 15.0,
        color: UIColors.primary);
  }

}