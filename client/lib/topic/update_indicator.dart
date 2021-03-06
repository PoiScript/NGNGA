import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ngnga/localizations.dart';

final _dateFormatter = DateFormat('HH:mm:ss');

class UpdateIndicator extends StatefulWidget {
  final Future<void> Function() fetch;

  const UpdateIndicator({
    Key key,
    @required this.fetch,
  })  : assert(fetch != null),
        super(key: key);

  @override
  _UpdateIndicatorState createState() => _UpdateIndicatorState();
}

class _UpdateIndicatorState extends State<UpdateIndicator>
    with WidgetsBindingObserver {
  StreamSubscription _streamSub;
  DateTime _lastUpdated = DateTime.now();

  bool _isLoading = false;

  bool _manuallyPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _streamSub =
        Stream.periodic(const Duration(seconds: 20)).listen((_) => _fetch());
    print('Start listening');
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _streamSub.cancel();
    print('Cancel listening');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _resumeListening();
    } else if (state == AppLifecycleState.inactive) {
      _pauseListening();
    }
  }

  _resumeListening() {
    if (!_manuallyPaused && _streamSub.isPaused) {
      _streamSub.resume();
      print('Resume listening');
    }
  }

  _pauseListening() {
    if (!_streamSub.isPaused) {
      _streamSub.pause();
      print('Pause listening');
    }
  }

  _fetch() async {
    setState(() {
      _isLoading = true;
    });
    await widget.fetch();
    setState(() {
      _lastUpdated = DateTime.now();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context).isCurrent) {
      _resumeListening();
    } else {
      _pauseListening();
    }

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
              if (_manuallyPaused) {
                _resumeListening();
                setState(() => _manuallyPaused = false);
              } else {
                _pauseListening();
                setState(() => _manuallyPaused = true);
              }
            },
          ),
          if (_manuallyPaused)
            Text(
              AppLocalizations.of(context).autoUpdateDisabled,
              style: Theme.of(context).textTheme.caption,
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).autoUpdateEnabled,
                  style: Theme.of(context).textTheme.caption,
                ),
                if (_isLoading)
                  Text(
                    AppLocalizations.of(context).loading,
                    style: Theme.of(context).textTheme.caption,
                  )
                else
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) => Text(
                      AppLocalizations.of(context).lastUpdated(
                        _dateFormatter.format(_lastUpdated),
                        DateTime.now().difference(_lastUpdated).inSeconds,
                      ),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                Text(
                  AppLocalizations.of(context).updateInterval(20),
                  style: Theme.of(context).textTheme.caption,
                )
              ],
            ),
        ],
      ),
    );
  }
}
