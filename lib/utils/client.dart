import 'package:http/http.dart';
import 'package:ngnga/store/state.dart';

class MyClient extends BaseClient {
  String userAgent = '';
  String _cookie = '';

  final Client _inner;

  MyClient() : _inner = Client();

  // update client cookies base on given userState
  void updateCookie(UserState userState) {
    if (userState is Logged) {
      _cookie =
          'ngaPassportUid=${userState.uid};ngaPassportCid=${userState.cid};';
    } else if (userState is Guest) {
      // TODO: guest login
      _cookie = 'ngaPassportUid=${userState.uid};';
    } else if (userState is Unlogged) {
      _cookie = '';
    }
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request.headers['user-agent'] = userAgent;
    request.headers.putIfAbsent('cookie', () => _cookie);
    return _inner.send(request);
  }
}
