import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';

import './screens/home/home.dart';
import './screens/settings/settings.dart';
import './screens/category/category.dart';
import './screens/topic/topic.dart';
import './screens/user/user.dart';
import './style.dart';
import './store/state.dart';
import './models/category.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = Store<AppState>(
      initialState: AppState(
        isLoading: false,
        categories: Map(),
        topics: Map(),
        users: Map(),
      ),
      actionObservers: [Log<AppState>.printer()],
      modelObserver: DefaultModelObserver(),
    );

    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        onGenerateRoute: _routes,
        theme: _theme(),
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
        screen = TopicPageConnector(arguments["id"]);
        break;
      case "/u":
        screen = UserPage(id: arguments["id"]);
        break;
      case "/s":
        screen = SettingsPage();
        break;
      default:
        return null;
    }
    return MaterialPageRoute(builder: (BuildContext context) => screen);
  }

  ThemeData _theme() {
    return ThemeData(
      textTheme: TextTheme(
        title: TitleTextStyle,
        subtitle: SubTitleTextStyle,
        caption: CaptionTextStyle,
        body1: Body1TextStyle,
      ),
    );
  }
}
