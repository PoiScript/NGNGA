import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import '../../app_state.dart';
import 'category_base_action.dart';

class LoadPreviousPageAction extends CategoryBaseAction {
  final int categoryId;
  final bool isSubcategory;

  LoadPreviousPageAction({
    @required this.categoryId,
    @required this.isSubcategory,
  })  : assert(categoryId != null),
        assert(isSubcategory != null);

  @override
  Future<AppState> reduce() async {
    assert(categoryState.initialized);
    assert(!categoryState.hasRechedMin);

    final res = await fetchCategoryTopics(
      categoryId: categoryId,
      pageIndex: categoryState.firstPage - 1,
      isSubcategory: isSubcategory,
    );

    return state.rebuild(
      (b) => b
        ..categoryStates[categoryId] = categoryState.rebuild(
          (b) => b
            ..topicIds = (SetBuilder(res.topics.map((t) => t.id))
              ..addAll(categoryState.topicIds))
            ..topicsCount = res.topicCount
            ..firstPage = categoryState.firstPage - 1
            ..maxPage = res.maxPage,
        )
        ..topicStates.update(udpateTopicState(res.topics)),
    );
  }
}
