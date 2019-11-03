import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import './topic_row.dart';
import '../../models/topic.dart';
import '../../models/category.dart';
import '../../store/state.dart';
import '../../store/fetch_topics.dart';

class CategoryPage extends StatelessWidget {
  final List<Topic> topics;

  CategoryPage({Key key, this.topics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: topics.isNotEmpty
          ? RefreshIndicator(
              onRefresh: () {
                return;
              },
              child: _buildList(context, topics),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildList(BuildContext context, List<Topic> topics) {
    return ListView.builder(
      itemCount: topics.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => _onTap(context, topics[index].id),
        child: TopicRow(topics[index]),
      ),
    );
  }

  _onTap(BuildContext context, int topicId) {
    Navigator.pushNamed(context, "/t", arguments: {"id": topicId});
  }
}

class CategoryPageConnector extends StatelessWidget {
  final int categoryId;

  CategoryPageConnector(this.categoryId, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(categoryId),
      // distinct: false,
      onInit: (st) => st.dispatch(FetchTopicsAction(
        category: Category(id: categoryId),
        page: 0,
      )),
      builder: (BuildContext context, ViewModel vm) =>
          CategoryPage(topics: vm.topics ?? []),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final categoryId;

  ViewModel(this.categoryId);

  List<Topic> topics;
  bool isLoading;
  Future<void> Function() onRefresh;

  ViewModel.build({
    @required this.topics,
    @required this.isLoading,
    @required this.categoryId,
    @required this.onRefresh,
  }) : super(equals: [isLoading, topics]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      topics: state.categories[categoryId]?.topicIds
          ?.map((id) => state.topics[id].topic)
          ?.toList(),
      isLoading: state.isLoading,
      onRefresh: () => dispatchFuture(FetchTopicsAction(
        category: Category(id: categoryId),
        page: 0,
      )),
      categoryId: categoryId,
    );
  }
}
