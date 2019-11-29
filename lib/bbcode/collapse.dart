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
  AnimationController _controller;
  Animation<double> _size;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _size = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void didUpdateWidget(Collapse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            child: Row(
              children: <Widget>[
                _expanded
                    ? Icon(Icons.arrow_drop_down)
                    : Icon(Icons.arrow_right),
                Expanded(
                  child: Text('${widget.description}...'),
                ),
              ],
            ),
            onTap: () {
              switch (_controller.status) {
                case AnimationStatus.completed:
                  _controller.reverse();
                  setState(() => _expanded = false);
                  break;
                case AnimationStatus.dismissed:
                  _controller.forward();
                  setState(() => _expanded = true);
                  break;
                default:
                  break;
              }
            },
          ),
          SizeTransition(
            axisAlignment: -1.0,
            sizeFactor: _size,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
