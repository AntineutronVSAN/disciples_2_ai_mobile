
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class SvgIcon extends StatelessWidget {

  final String asset;
  final Color? color;
  final double size;

  const SvgIcon({
    Key? key,
    required this.asset,
    required this.color,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
          'assets/icons/' + asset,
          color: color,
      ),
    );
  }

}