import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import 'package:business/repository/responses/fetch_topic_posts_response.dart';
import 'package:business/repository/responses/fetch_category_topics.dart';
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

  Future<FetchCategoryTopicsResponse> fetchCategoryTopics({
    @required int categoryId,
    @required int pageIndex,
    @required bool isSubcategory,
  }) =>
      state.repository.fetchCategoryTopics(
        cookie: state.userState.cookie,
        baseUrl: state.settings.baseUrl,
        categoryId: categoryId,
        isSubcategory: isSubcategory,
        page: pageIndex,
      );

  Future<FetchTopicPostsResponse> fetchTopicPosts({
    @required int topicId,
    @required int pageIndex,
  }) =>
      state.repository.fetchTopicPosts(
        cookie: state.userState.cookie,
        baseUrl: state.settings.baseUrl,
        topicId: topicId,
        page: pageIndex,
      );
}
