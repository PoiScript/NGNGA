import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:business/app_state.dart';
import 'package:business/settings/models/settings_state.dart';
import 'package:ngnga/localizations.dart';
import 'package:ngnga/category/category_page_connector.dart';
import 'package:ngnga/editor/editor_page_connector.dart';
import 'package:ngnga/home/home_page_connector.dart';
import 'package:ngnga/settings/settings_page_connector.dart';
import 'package:ngnga/topic/topic_page_connector.dart';
import 'package:ngnga/user/user_page_connector.dart';
import 'package:ngnga/welcome/welcome_page_connector.dart';
import 'package:ngnga/style.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = Store<AppState>(
    initialState: await AppState.load(),
    // actionObservers: [Log<AppState>.printer()],
    // modelObserver: DefaultModelObserver(),
  );

  return runApp(MyApp(store: store));
}

final Map<AppTheme, ThemeData> themeDataMap = {
  AppTheme.white: whiteTheme,
  AppTheme.black: blackTheme,
  AppTheme.grey: greyTheme,
  AppTheme.yellow: yellowTheme,
};

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  MyApp({@required this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: StoreConnector<AppState, _ViewModel>(
        model: _ViewModel(),
        builder: (context, vm) => MaterialApp(
          onGenerateRoute: _routes,
          theme: themeDataMap[vm.theme],
          initialRoute: store.state.userState.isLogged ? '/' : 'welcome',
          locale: vm.locale.toLocale(),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            const AppLocalizationsDelegate(),
          ],
          supportedLocales: [
            const Locale('en', ''),
            const Locale('zh', ''),
            // TODO: chinese variants
            // const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
            // const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
          ],
        ),
      ),
    );
  }

  Route<dynamic> _routes(RouteSettings settings) {
    Map<String, dynamic> arguments = settings.arguments;
    Widget screen;
    switch (settings.name) {
      case '/':
        screen = HomePageConnector();
        break;
      case '/c':
        screen = CategoryPageConnector(
          categoryId: arguments['id'],
          isSubcategory: arguments['isSubcategory'],
          pageIndex: arguments['page'],
        );
        break;
      case '/t':
        screen = TopicPageConnector(
          topicId: arguments['id'],
          pageIndex: arguments['page'],
        );
        break;
      case '/u':
        screen = UserPageConnector(
          userId: arguments['uesrId'],
        );
        break;
      case '/s':
        screen = SettingsPageConnector();
        break;
      case '/e':
        screen = EditorPageConnector(
          action: arguments['action'],
          categoryId: arguments['categoryId'],
          topicId: arguments['topicId'],
          postId: arguments['postId'],
        );
        break;
      // use 'welcome' instead of '/welcome' to make sure it's a top-level route
      case 'welcome':
        screen = WelcomePageConnector();
        break;
      default:
        return null;
    }
    return MaterialPageRoute(builder: (context) => screen);
  }
}

class _ViewModel extends BaseModel<AppState> {
  _ViewModel();

  AppTheme theme;
  AppLocale locale;

  _ViewModel.build({
    @required this.theme,
    @required this.locale,
  }) : super(equals: [theme, locale]);

  @override
  _ViewModel fromStore() => _ViewModel.build(
        theme: state.settings.theme,
        locale: state.settings.locale,
      );
}
