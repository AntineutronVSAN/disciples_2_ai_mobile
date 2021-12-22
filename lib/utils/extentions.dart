
import 'package:flutter/material.dart';

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension on Color {
  Color operator +(Color other) => Color.alphaBlend(this, other);
}
