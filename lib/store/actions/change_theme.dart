import 'package:async_redux/async_redux.dart';
import 'package:ngnga/store/state.dart';

class ChangeThemeAction extends ReduxAction<AppState> {
  final AppTheme theme;

  ChangeThemeAction(this.theme);

  @override
  AppState reduce() {
    return state.copy(
      settings: state.settings.copy(
        theme: theme,
      ),
    );
  }
}
