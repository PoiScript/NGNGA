import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ngnga/localizations.dart';

import 'package:ngnga/screens/category/category.dart';
import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/screens/home/home.dart';
import 'package:ngnga/screens/welcome/welcome.dart';
import 'package:ngnga/screens/settings/settings.dart';
import 'package:ngnga/screens/topic/topic.dart';
import 'package:ngnga/screens/user/user.dart';
import 'package:ngnga/store/actions/state_persist.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/style.dart';

void main() async {
  final store = Store<AppState>(
    initialState: AppState.empty(),
    // actionObservers: [Log<AppState>.printer()],
    // modelObserver: DefaultModelObserver(),
  );

  await store.dispatchFuture(LoadState());

  return runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  MyApp({@required this.store});

  @override
  Widget build(BuildContext context) {
    final _navigatorKey = GlobalKey<NavigatorState>();

    NavigateAction.setNavigatorKey(_navigatorKey);

    return StoreProvider<AppState>(
      store: store,
      child: StoreConnector<AppState, ViewModel>(
        model: ViewModel(),
        builder: (context, vm) => MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateRoute: _routes,
          navigatorKey: _navigatorKey,
          theme: _mapToThemeData(vm.theme),
          initialRoute: store.state.userState == null ? 'welcome' : '/',
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
    final Map<String, int> arguments = settings.arguments;
    Widget screen;
    switch (settings.name) {
      case '/':
        screen = HomePage();
        break;
      case '/c':
        screen = CategoryPageConnector(
          categoryId: arguments['id'],
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

  ThemeData _mapToThemeData(AppTheme theme) {
    ThemeData themeData;
    switch (theme) {
      case AppTheme.white:
        themeData = whiteTheme;
        break;
      case AppTheme.black:
        themeData = blackTheme;
        break;
      case AppTheme.grey:
        themeData = greyTheme;
        break;
      case AppTheme.yellow:
        themeData = yellowTheme;
        break;
    }
    return themeData;
  }
}

class ViewModel extends BaseModel<AppState> {
  ViewModel();

  AppTheme theme;

  ViewModel.build({@required this.theme}) : super(equals: [theme]);

  @override
  ViewModel fromStore() => ViewModel.build(theme: state.settings.theme);
}
