import 'package:gbk_codec/gbk_codec.dart';

String encodeUrlGbk(String text) {
  final sb = StringBuffer();

  for (final code in gbk.encode(text)) {
    if (code <= 0x000F) {
      sb..write('%0')..write(code.toRadixString(16));
    } else if (code <= 0x00FF) {
      sb..write('%')..write(code.toRadixString(16));
    } else if (code <= 0x0FFF) {
      sb..write('%0')..write(((code >> 8) & 0xFF)..toRadixString(16));
      sb..write('%')..write((code & 0xFF).toRadixString(16));
    } else {
      sb..write('%')..write(((code >> 8) & 0xFF).toRadixString(16));
      sb..write('%')..write((code & 0xFF).toRadixString(16));
    }
  }

  return sb.toString();
}
