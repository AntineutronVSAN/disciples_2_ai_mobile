

import 'package:flutter/material.dart';

abstract class DowloadableStateless extends StatelessWidget {

  final bool? loading;
  final SkeletonOptions? options;

  const DowloadableStateless({Key? key,
    this.loading,
    this.options,

  }) : super(key: key);

  Widget buildBody(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: (loading ?? false) && options != null
        ? LoadingSkeleton(options: options!,)
        : buildBody(context),
    );
  }
}

class LoadingSkeleton extends StatelessWidget {

  final SkeletonOptions options;

  const LoadingSkeleton({Key? key, required this.options}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: options.padding,
      child: Container(
        width: options.estimatedWidth,
        height: options.estimatedHeight,
        decoration: BoxDecoration(
          color: options.skeletonColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: options.info != null
            ? Center(child: Text(options.info!, style: options.infoStyle,))
            : const SizedBox.shrink(),
      ),
    );
  }
}

class SkeletonOptions {

  final double estimatedWidth;
  final double estimatedHeight;
  final Color skeletonColor;
  final EdgeInsets padding;
  final TextStyle? infoStyle;
  final String? info;

  const SkeletonOptions({
    required this.estimatedWidth,
    required this.estimatedHeight,
    required this.skeletonColor,
    required this.padding,
    this.info,
    this.infoStyle,
  });

}