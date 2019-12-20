import 'package:flutter/foundation.dart';

import '../../app_state.dart';
import '../models/topic_state.dart';
import 'topic_base_action.dart';

class ClearTopicAction extends TopicBaseAction {
  final int topicId;

  ClearTopicAction({
    @required this.topicId,
  }) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    return state.rebuild(
      (b) => b
        ..posts.removeWhere((id, _) => topicState.postIds.contains(id))
        ..topicStates.updateValue(
          topicId,
          (topicState) => topicState.rebuild(
            (b) => b
              ..initialized = false
              ..postIds.clear(),
          ),
          ifAbsent: () => TopicState(),
        ),
    );
  }
}
