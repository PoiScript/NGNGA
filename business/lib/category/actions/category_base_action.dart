import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';

import '../../app_state.dart';
import '../../models/topic.dart';
import '../../topic/models/topic_state.dart';
import '../models/category_state.dart';

abstract class CategoryBaseAction extends ReduxAction<AppState> {
  int get categoryId;

  CategoryState get categoryState => state.categoryStates[categoryId];

  Function(MapBuilder<int, TopicState>) udpateTopicState(List<Topic> topics) {
    return (MapBuilder<int, TopicState> b) {
      for (Topic topic in topics) {
        b.updateValue(
          topic.id,
          (topicState) => topicState.rebuild((b) => b.topic = topic),
          ifAbsent: () => TopicState((b) => b.topic = topic),
        );
      }
    };
  }
}
