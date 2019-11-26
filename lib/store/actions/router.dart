import 'package:async_redux/async_redux.dart';

import '../state.dart';

class NavigateToCategoryAction extends ReduxAction<AppState> {
  final int categoryId;

  NavigateToCategoryAction(this.categoryId) : assert(categoryId != null);

  @override
  AppState reduce() {
    // TODO: what if state.category[categoryId] doesn't exist

    return state.copy(
      categoryStates: state.categoryStates
        ..putIfAbsent(
          categoryId,
          () => CategoryState(
            topicIds: List(),
            lastPage: 0,
            topicsCount: 0,
            maxPage: 0,
          ),
        ),
    );
  }

  void after() =>
      dispatch(NavigateAction.pushNamed("/c", arguments: {"id": categoryId}));
}

class NavigateToTopicAction extends ReduxAction<AppState> {
  final int topicId;
  final int page;

  NavigateToTopicAction(this.topicId, this.page)
      : assert(topicId != null && page != null);

  @override
  AppState reduce() {
    // TODO: what if state.topic[topicId] doesn't exist

    return state.copy(
      topicStates: state.topicStates
        ..update(
          topicId,
          (topicState) => topicState.copy(
            postIds: topicState.firstPage != page ? List() : null,
            postsCount: topicState.firstPage != page ? 0 : null,
          ),
          ifAbsent: () => TopicState(
            firstPage: page,
            lastPage: page,
            maxPage: page,
            postsCount: 0,
            postIds: List(),
          ),
        ),
    );
  }

  void after() => dispatch(
      NavigateAction.pushNamed("/t", arguments: {"id": topicId, "page": page}));
}
