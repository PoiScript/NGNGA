import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';

final dateFormatter = DateFormat("HH:mm:ss");

class UpdateIndicator extends StatefulWidget {
  final DateTime lastUpdated;
  final Future<void> Function() startListening;
  final Future<void> Function() cancelListening;

  UpdateIndicator({
    Key key,
    @required this.lastUpdated,
    @required this.startListening,
    @required this.cancelListening,
  }) : super(key: key);

  @override
  _UpdateIndicatorState createState() => _UpdateIndicatorState();
}

class _UpdateIndicatorState extends State<UpdateIndicator> {
  bool isListening = true;

  @override
  void initState() {
    super.initState();
    widget.startListening();
  }

  @override
  void dispose() {
    super.dispose();
    if (isListening) widget.cancelListening();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + kFloatingActionButtonMargin * 2 - 8,
      padding: EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.replay,
              color: Theme.of(context).textTheme.caption.color,
            ),
            onPressed: () {
              if (isListening) {
                widget.cancelListening();
              } else {
                widget.startListening();
              }
              setState(() => isListening = !isListening);
            },
          ),
          isListening
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Auto-update enabled.",
                      style: Theme.of(context).textTheme.caption,
                    ),
                    StreamBuilder(
                      initialData: DateTime.now(),
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) => Text(
                        "Last Updated: ${dateFormatter.format(widget.lastUpdated)} (${DateTime.now().difference(widget.lastUpdated).inSeconds}s ago)",
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                    Text(
                      "Update Interval: 20s",
                      style: Theme.of(context).textTheme.caption,
                    )
                  ],
                )
              : Text(
                  "Auto-update disabled.",
                  style: Theme.of(context).textTheme.caption,
                ),
        ],
      ),
    );
  }
}

class UpdateIndicatorConnector extends StatelessWidget {
  final int topicId;

  UpdateIndicatorConnector({
    @required this.topicId,
  }) : assert(topicId != null);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(topicId),
      builder: (context, vm) => UpdateIndicator(
        lastUpdated: vm.lastUpdated,
        startListening: vm.startListening,
        cancelListening: vm.cancelListening,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final topicId;

  DateTime lastUpdated;
  Future<void> Function() startListening;
  Future<void> Function() cancelListening;

  ViewModel(this.topicId);

  ViewModel.build({
    @required this.topicId,
    @required this.lastUpdated,
    @required this.startListening,
    @required this.cancelListening,
  }) : super(equals: [lastUpdated]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      topicId: topicId,
      lastUpdated: state.lastUpdated,
      startListening: () => dispatchFuture(
        StartListeningNewReplyAction(topicId),
      ),
      cancelListening: () => dispatchFuture(
        CancelListeningNewReplyAction(),
      ),
    );
  }
}
