import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import '../../app_state.dart';
import 'category_base_action.dart';

class RefreshFirstPageAction extends CategoryBaseAction {
  final int categoryId;
  final bool isSubcategory;

  RefreshFirstPageAction({
    @required this.categoryId,
    @required this.isSubcategory,
  })  : assert(categoryId != null),
        assert(isSubcategory != null);

  @override
  Future<AppState> reduce() async {
    assert(categoryState.initialized);
    assert(categoryState.firstPage == 0);

    final res = await fetchCategoryTopics(
      categoryId: categoryId,
      isSubcategory: isSubcategory,
      pageIndex: 0,
    );

    return state.rebuild(
      (b) => b
        ..categoryStates[categoryId] = categoryState.rebuild(
          (b) => b
            ..topicIds = SetBuilder(res.topics.map((t) => t.id))
            ..topicsCount = res.topicCount
            ..maxPage = res.maxPage
            ..firstPage = 0,
        )
        ..topicStates.update(udpateTopicState(res.topics)),
    );
  }
}
