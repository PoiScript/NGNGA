import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const double _itemExtent = 50.0;

const double _listHeigth = _itemExtent * 3;

class PagePicker extends StatefulWidget {
  PagePicker({
    Key key,
    @required this.initialPage,
    @required this.maxPage,
  })  : assert(initialPage != null),
        assert(maxPage != null),
        assert(initialPage <= maxPage),
        super(key: key);

  final int initialPage;

  final int maxPage;

  @override
  _PagePickerState createState() => _PagePickerState();
}

class _PagePickerState extends State<PagePicker> {
  ScrollController scrollController;
  int selectedPage;

  @override
  void initState() {
    super.initState();
    selectedPage = widget.initialPage;
    scrollController =
        ScrollController(initialScrollOffset: widget.initialPage * _itemExtent)
          ..addListener(() {
            int currentPage = (scrollController.offset / _itemExtent).round();

            if (currentPage >= 0 &&
                currentPage <= widget.maxPage &&
                currentPage != selectedPage) {
              setState(() => selectedPage = currentPage);
            }
          });
  }

  _animateTo(double offset) {
    scrollController.animateTo(
      offset,
      duration: Duration(seconds: 1),
      curve: ElasticOutCurve(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Page Picker'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: _listHeigth,
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.idle &&
                    scrollController.position.activity is! HoldScrollActivity) {
                  _animateTo(selectedPage * _itemExtent);
                }
              },
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: _itemExtent),
                controller: scrollController,
                itemExtent: _itemExtent,
                itemCount: widget.maxPage + 1,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) => Center(
                  child: Text(
                    (index + 1).toString(),
                    style: index == selectedPage
                        ? Theme.of(context)
                            .textTheme
                            .headline
                            .copyWith(color: Theme.of(context).accentColor)
                        : Theme.of(context).textTheme.body1,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              'PostIndex: ${selectedPage * 20} ~ ${(selectedPage + 1) * 20}',
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context, selectedPage),
          child: Text('Select'),
        ),
      ],
    );
  }
}
