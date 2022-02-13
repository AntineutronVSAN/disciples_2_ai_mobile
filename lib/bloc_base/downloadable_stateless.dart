import 'package:flutter/material.dart';

const int switcherDurationMilliseconds = 500;

/// Базовый класс для статичного виждета, который может загружаться
/// При статусе загрузки, вместо контента отображается скелетон
/// В поле [SkeletonOptions] можно задать внешний вид скелетона
/// Переопределите метод [buildBody] для постоения виждета
abstract class DownloadableStateless extends StatelessWidget {
  final bool? loading;
  final SkeletonOptions? options;

  const DownloadableStateless({
    Key? key,
    this.loading,
    this.options,
  }) : super(key: key);

  Widget buildBody(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: switcherDurationMilliseconds),
      child: (loading ?? false) && options != null
          ? LoadingSkeleton(
              options: options!,
            )
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
            borderRadius: BorderRadius.circular(options.skeletonBorderRadius),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              options.info != null
                  ? Text(
                      options.info!,
                      style: options.infoStyle,
                      textAlign: TextAlign.center,
                    )
                  : const SizedBox.shrink(),
              SizedBox(
                height: options.infoProgressSpace,
              ),
              SizedBox(
                width: options.progressIndicatorSize,
                height: options.progressIndicatorSize,
                child: CircularProgressIndicator(
                  color: options.infoStyle?.color,
                  strokeWidth: options.progressIndicatorSize /
                      options.progressIndicatorStrokeWidthCoeff,
                ),
              )
            ],
          )),
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

  final double progressIndicatorSize;
  final double infoProgressSpace;
  final int progressIndicatorStrokeWidthCoeff;
  final double skeletonBorderRadius;

  const SkeletonOptions({
    required this.estimatedWidth,
    required this.estimatedHeight,
    required this.skeletonColor,
    required this.padding,
    this.info,
    this.infoStyle,
    this.infoProgressSpace = 5.0,
    this.progressIndicatorSize = 15.0,
    this.progressIndicatorStrokeWidthCoeff = 6,
    this.skeletonBorderRadius = 10.0,
  });
}
