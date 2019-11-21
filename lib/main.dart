import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/screens/category/category.dart';
import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/screens/explore/explore.dart';
import 'package:ngnga/screens/home/home.dart';
import 'package:ngnga/screens/new/new.dart';
import 'package:ngnga/screens/settings/settings.dart';
import 'package:ngnga/screens/topic/topic.dart';
import 'package:ngnga/screens/user/user.dart';
import 'package:ngnga/store/persistor.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/style.dart';

main() async {
  final persistor = await JsonPersistor.init();

  var initialState = await persistor.readState();

  if (initialState == null) {
    initialState = AppState.empty();
    await persistor.saveInitialState(initialState);
  }

  return runApp(MyApp(
    persistor: persistor,
    state: initialState,
  ));
}

class MyApp extends StatelessWidget {
  final Persistor persistor;
  final AppState state;

  MyApp({
    @required this.persistor,
    @required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final _navigatorKey = GlobalKey<NavigatorState>();

    NavigateAction.setNavigatorKey(_navigatorKey);

    final _store = Store<AppState>(
      initialState: state,
      // actionObservers: [Log<AppState>.printer()],
      // modelObserver: DefaultModelObserver(),
    );

    return StoreProvider<AppState>(
      store: _store,
      child: MaterialApp(
        onGenerateRoute: _routes,
        navigatorKey: _navigatorKey,
        theme: _theme,
        // use "new" instead of "/new" to make sure it's a top-level route
        initialRoute: state.cookies.isEmpty ? "new" : "/",
      ),
    );
  }

  Route<dynamic> _routes(RouteSettings settings) {
    final Map<String, int> arguments = settings.arguments;
    Widget screen;
    switch (settings.name) {
      case "/":
        screen = HomePageConnector();
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
      case "new":
        screen = NewPage();
        break;
      case "explore":
        screen = ExplorePage();
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
