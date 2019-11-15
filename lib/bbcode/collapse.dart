import 'package:flutter/material.dart';

class Collapse extends StatefulWidget {
  final String description;
  final Widget child;

  Collapse({
    @required this.description,
    @required this.child,
  });

  @override
  _CollapseState createState() => _CollapseState();
}

class _CollapseState extends State<Collapse> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            child: Container(
              height: 24.0,
              child: Row(
                children: <Widget>[
                  _expanded
                      ? Icon(Icons.arrow_drop_down)
                      : Icon(Icons.arrow_right),
                  Text("${widget.description}.."),
                ],
              ),
            ),
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 500),
            firstChild: Container(),
            secondChild: widget.child,
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }
}
