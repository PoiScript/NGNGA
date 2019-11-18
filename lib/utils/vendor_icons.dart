import 'package:flutter/widgets.dart';
import 'package:ngnga/models/post.dart';

class VendorIcons {
  VendorIcons._();

  static const _kFontFam = 'VendorIcon';

  static const IconData android = const IconData(0xe800, fontFamily: _kFontFam);
  static const IconData apple = const IconData(0xf179, fontFamily: _kFontFam);
  static const IconData windows = const IconData(0xf17a, fontFamily: _kFontFam);

  static IconData fromClient(Client client) {
    return client == Client.Android
        ? VendorIcons.android
        : (client == Client.Apple ? VendorIcons.apple : VendorIcons.windows);
  }
}
