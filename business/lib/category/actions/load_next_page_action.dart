import '../../app_state.dart';
import 'category_base_action.dart';

class LoadNextPageAction extends CategoryBaseAction {
  final int categoryId;
  final bool isSubcategory;

  LoadNextPageAction({
    this.categoryId,
    this.isSubcategory,
  })  : assert(categoryId != null),
        assert(isSubcategory != null);

  @override
  Future<AppState> reduce() async {
    assert(categoryState.initialized);
    assert(!categoryState.hasRechedMax);

    final res = await state.repository.fetchCategoryTopics(
      categoryId: categoryId,
      page: categoryState.lastPage + 1,
      isSubcategory: isSubcategory,
    );

    return state.rebuild(
      (b) => b
        ..categoryStates[categoryId] = categoryState.rebuild(
          (b) => b
            ..topicIds.addAll(res.topics.map((t) => t.id))
            ..topicsCount = res.topicCount
            ..lastPage = categoryState.lastPage + 1
            ..maxPage = res.maxPage,
        )
        ..topicStates.update(udpateTopicState(res.topics)),
    );
  }
}
