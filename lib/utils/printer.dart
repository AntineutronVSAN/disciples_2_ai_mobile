

class CustomPrinter {
  static const PrinterMode mode = PrinterMode.debug;

  static void printVal(dynamic value, {PrintType type = PrintType.info}) {
    if (CustomPrinter.mode == PrinterMode.debug) {
      switch (type) {
        case PrintType.info:
          print('INFO: ----------------> ${value.toString()}');
          break;
        case PrintType.warning:
          print('WARNING: ----------------> ${value.toString()}');
          break;
        case PrintType.error:
          print('ERROR: ----------------> ${value.toString()}');
          break;
      }
    }
  }

}

enum PrinterMode {
  debug,
  release
}

enum PrintType {
  info,
  warning,
  error
}