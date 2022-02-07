

import 'dart:typed_data';

class BytesUtils {


  static int uint8List2Uint32(Uint8List bytes) {
    return bytes.buffer.asByteData().getUint32(0);
  }

}