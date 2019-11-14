import 'dart:async';
import 'dart:math';

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

class _CollapseState extends State<Collapse>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      // mainAxisAlignment: MainAxis,
      children: <Widget>[
        GestureDetector(
          child: Container(
            height: 24.0,
            child: Row(
              children: <Widget>[
                AnimatedBuilder(
                  animation: _animationController,
                  child: Icon(Icons.arrow_right),
                  builder: (context, widget) {
                    return Transform.rotate(
                      angle: _animationController.value * pi,
                      child: widget,
                    );
                  },
                ),
                Text(widget.description),
              ],
            ),
          ),
          onTap: () {
            setState(() {
              if (_expanded) {
                _animationController.reverse();
              } else {
                _animationController.repeat();
              }
              Timer(const Duration(milliseconds: 500), () {
                _animationController.stop();
              });
              _expanded = !_expanded;
            });
          },
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 500),
          firstChild: Container(),
          secondChild: widget.child,
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        ),
      ],
    );
  }
}
