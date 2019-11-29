import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ngnga/models/topic.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/duration.dart';
import 'package:ngnga/widgets/title_colorize.dart';

final NumberFormat numberFormatter = NumberFormat('#,###');
final DateFormat dateFormatter = DateFormat('yyyy-MM-dd HH:mm');

class TopicRow extends StatelessWidget {
  final Topic topic;

  final void Function(int, int) navigateToTopic;
  final void Function(int) navigateToCategory;

  TopicRow({
    @required this.topic,
    @required this.navigateToTopic,
    @required this.navigateToCategory,
  })  : assert(topic != null),
        assert(navigateToTopic != null),
        assert(navigateToCategory != null);

  @override
  Widget build(BuildContext context) {
    if (topic.category != null) {
      return InkWell(
        onTap: () => navigateToCategory(topic.category.id),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TitleColorize(topic),
              ),
              const Icon(Icons.keyboard_arrow_right)
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        InkWell(
          onTap: () => navigateToTopic(topic.id, 0),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
            child: TitleColorize(topic),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              width: 64,
              padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
              child: Text(
                numberFormatter.format(topic.postsCount),
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 4, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Text(
                          topic.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                    ),
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(minutes: 1)),
                      builder: (context, snapshot) => Text(
                        duration(DateTime.now(), topic.createdAt),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                child: Container(
                  padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Text(
                            topic.lastPoster,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                      ),
                      StreamBuilder(
                        stream: Stream.periodic(const Duration(minutes: 1)),
                        builder: (context, snapshot) => Text(
                          duration(DateTime.now(), topic.lastPostedAt),
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () => navigateToTopic(topic.id, topic.postsCount ~/ 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TopicRowConnector extends StatelessWidget {
  final Topic topic;

  TopicRowConnector(this.topic);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(topic.id),
      builder: (context, vm) => TopicRow(
        topic: topic,
        navigateToCategory: vm.navigateToCategory,
        navigateToTopic: vm.navigateToTopic,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final int topicId;

  ViewModel(this.topicId);

  Function(int, int) navigateToTopic;
  Function(int) navigateToCategory;

  ViewModel.build({
    @required this.topicId,
    @required this.navigateToCategory,
    @required this.navigateToTopic,
  });

  @override
  BaseModel fromStore() {
    return ViewModel.build(
      topicId: topicId,
      navigateToCategory: (id) => dispatch(NavigateToCategoryAction(id)),
      navigateToTopic: (id, page) => dispatch(NavigateToTopicAction(id, page)),
    );
  }
}
