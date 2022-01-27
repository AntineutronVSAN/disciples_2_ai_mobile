

import 'package:d2_ai_v2/utils/svg_picture.dart';
import 'package:flutter/material.dart';

class ClickableSvg extends StatelessWidget {

  final VoidCallback? onTap;
  final String asset;
  final Color? color;
  final double size;
  final EdgeInsets padding;

  ClickableSvg({

    this.onTap,
    this.color,
    required this.asset,
    required this.size,
    this.padding = const EdgeInsets.all(0.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: InkWell(
          onTap: onTap,
          child: SvgIcon(
            asset: asset,
            color: color,
            size: size,
          )),
    );
  }

}