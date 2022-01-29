

import 'package:d2_ai_v2/theme/colors.dart';
import 'package:flutter/material.dart';



PreferredSizeWidget? getThemeAppBar({
    Color backgroundColor = UIColors.primaryAppBarColor,
    Widget? title,
    bool centerTitle = true,
    Widget? leading,
  }) {

  return AppBar(
    backgroundColor: backgroundColor,
    title: title,
    centerTitle: centerTitle,
    leading: leading,
  );
}


