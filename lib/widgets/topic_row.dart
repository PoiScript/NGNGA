import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ngnga/models/category.dart';

import 'package:ngnga/models/topic.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/duration.dart';
import 'package:ngnga/widgets/title_colorize.dart';

final numberFormatter = NumberFormat("#,###");
final dateFormatter = DateFormat("yyyy-MM-dd HH:mm");

class TopicRow extends StatelessWidget {
  final Topic topic;

  final void Function(Topic, int) navigateToTopic;
  final void Function(Category) navigateToCategory;

  TopicRow({
    this.topic,
    this.navigateToTopic,
    this.navigateToCategory,
  })  : assert(topic != null),
        assert(navigateToTopic != null),
        assert(navigateToCategory != null);

  @override
  Widget build(BuildContext context) {
    if (topic.category != null)
      return InkWell(
        onTap: () => navigateToCategory(topic.category),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              TitleColorize(topic),
              const Spacer(),
              const Icon(Icons.keyboard_arrow_right)
            ],
          ),
        ),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        InkWell(
          onTap: () => navigateToTopic(topic, 0),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
            child: TitleColorize(topic),
          ),
        ),
        StreamBuilder<DateTime>(
          initialData: DateTime.now(),
          stream: Stream.periodic(Duration(minutes: 1), (x) => DateTime.now()),
          builder: (context, snapshot) => Row(
            children: <Widget>[
              Container(width: 8.0),
              Container(
                width: 46.0,
                child: Text(
                  numberFormatter.format(topic.postsCount),
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
              Container(width: 4.0),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        topic.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                    Container(width: 4.0),
                    Text(
                      duration(snapshot.data, topic.createdAt),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ),
              Container(width: 8.0),
              Expanded(
                child: InkWell(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          topic.lastPoster,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                      Container(width: 4.0),
                      Text(
                        duration(snapshot.data, topic.lastPostedAt),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Container(width: 8.0),
                    ],
                  ),
                  onTap: () => navigateToTopic(topic, topic.postsCount ~/ 20),
                ),
              ),
            ],
          ),
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
      model: ViewModel(),
      builder: (context, vm) => TopicRow(
        topic: topic,
        navigateToCategory: vm.navigateToCategory,
        navigateToTopic: vm.navigateToTopic,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  void Function(Topic, int) navigateToTopic;
  void Function(Category) navigateToCategory;

  ViewModel();

  ViewModel.build({
    @required this.navigateToCategory,
    @required this.navigateToTopic,
  });

  @override
  BaseModel fromStore() {
    return ViewModel.build(
      navigateToCategory: (category) =>
          dispatch(NavigateToCategoryAction(category)),
      navigateToTopic: (topic, page) =>
          dispatch(NavigateToTopicAction(topic, page)),
    );
  }
}
