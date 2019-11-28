import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

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

main() async {
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
      child: MaterialApp(
        onGenerateRoute: _routes,
        navigatorKey: _navigatorKey,
        theme: _theme,
        initialRoute: store.state.userState == null ? "welcome" : "/",
      ),
    );
  }

  Route<dynamic> _routes(RouteSettings settings) {
    final Map<String, int> arguments = settings.arguments;
    Widget screen;
    switch (settings.name) {
      case "/":
        screen = HomePage();
        break;
      case "/c":
        screen = CategoryPageConnector(arguments["id"]);
        break;
      case "/t":
        screen = TopicPageConnector(
          topicId: arguments["id"],
          pageIndex: arguments["page"],
        );
        break;
      case "/u":
        screen = UserPage(id: arguments["id"]);
        break;
      case "/s":
        screen = SettingsPageConnector();
        break;
      case "/e":
        screen = EditorPageConnector(
          action: arguments["action"],
          categoryId: arguments["categoryId"],
          topicId: arguments["topicId"],
          postId: arguments["postId"],
        );
        break;
      // use "welcome" instead of "/welcome" to make sure it's a top-level route
      case "welcome":
        screen = WelcomePageConnector();
        break;
      default:
        return null;
    }
    return MaterialPageRoute(builder: (context) => screen);
  }

  final ThemeData _theme = ThemeData(
    fontFamily: "Roboto",
    textTheme: TextTheme(
      title: TitleTextStyle,
      subtitle: SubTitleTextStyle,
      caption: CaptionTextStyle,
      subhead: SubheadTextStyle,
      body1: Body1TextStyle,
      body2: Body2TextStyle,
    ),
  );
}
