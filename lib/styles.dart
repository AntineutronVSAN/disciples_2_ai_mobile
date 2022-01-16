import 'package:flutter/material.dart';


class GameStyles {

  static TextStyle getUnitShortDescriptionStyle() {
    return const TextStyle(
        fontSize: 12.0,
        color: Colors.black,
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
        color: Colors.black);
  }

}