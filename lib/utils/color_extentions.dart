import 'package:flutter/material.dart';

extension on Color {
  Color operator +(Color other) => Color.alphaBlend(this, other);
}