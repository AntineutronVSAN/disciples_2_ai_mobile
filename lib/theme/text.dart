


import 'package:flutter/material.dart';

import '../styles.dart';

class ThemeAppText extends StatelessWidget {

  final String text;
  final TextStyle style;

  const ThemeAppText({Key? key,
    required this.text,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
    );
  }

}