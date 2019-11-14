import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/screens/category/category.dart';
import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/screens/home/home.dart';
import 'package:ngnga/screens/settings/settings.dart';
import 'package:ngnga/screens/topic/topic.dart';
import 'package:ngnga/screens/user/user.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/style.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _navigatorKey = GlobalKey<NavigatorState>();

    NavigateAction.setNavigatorKey(_navigatorKey);

    final _store = Store<AppState>(
      initialState: AppState(
        isLoading: false,
        categories: Map(),
        topics: Map(),
        users: Map(),
        savedCategories: List(),
        favorTopics: List(),
      ),
      actionObservers: [Log<AppState>.printer()],
      modelObserver: DefaultModelObserver(),
    );

    return StoreProvider<AppState>(
      store: _store,
      child: MaterialApp(
        onGenerateRoute: _routes,
        navigatorKey: _navigatorKey,
        theme: _theme,
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
        screen = TopicPageConnector(arguments["id"], arguments["page"]);
        break;
      case "/u":
        screen = UserPage(id: arguments["id"]);
        break;
      case "/s":
        screen = SettingsPageConnector();
        break;
      case "/e":
        screen = EditorPage();
        break;
      default:
        return null;
    }
    return MaterialPageRoute(builder: (context) => screen);
  }

  final ThemeData _theme = ThemeData(
    fontFamily: "Noto Sans CJK SC",
    textTheme: TextTheme(
      title: TitleTextStyle,
      subtitle: SubTitleTextStyle,
      caption: CaptionTextStyle,
      body1: Body1TextStyle,
    ),
  );
}
