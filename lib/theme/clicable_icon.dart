

import 'package:flutter/material.dart';

class ClickableIcon extends StatelessWidget {

  final Widget icon;
  final Function()? onPress;

  const ClickableIcon({Key? key,
    required this.icon,
    this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: icon,
    );
  }




}