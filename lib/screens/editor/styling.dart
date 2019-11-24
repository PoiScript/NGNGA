import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EditorStyling extends StatelessWidget {
  final VoidCallback insertBold;
  final VoidCallback insertItalic;
  final VoidCallback insertUnderline;
  final VoidCallback insertDelete;
  final VoidCallback insertQuote;
  final VoidCallback insertHeading;

  EditorStyling({
    @required this.insertBold,
    @required this.insertItalic,
    @required this.insertUnderline,
    @required this.insertDelete,
    @required this.insertQuote,
    @required this.insertHeading,
  })  : assert(insertBold != null),
        assert(insertItalic != null),
        assert(insertUnderline != null),
        assert(insertDelete != null),
        assert(insertQuote != null),
        assert(insertHeading != null);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          delegate: SliverChildListDelegate(
            [
              ToolbarIcon(
                icon: Icons.format_bold,
                onTap: insertBold,
              ),
              ToolbarIcon(
                icon: Icons.format_italic,
                onTap: insertItalic,
              ),
              ToolbarIcon(
                icon: Icons.format_underlined,
                onTap: insertUnderline,
              ),
              ToolbarIcon(
                icon: Icons.format_quote,
                onTap: insertQuote,
              ),
              ToolbarIcon(
                icon: Icons.format_strikethrough,
                onTap: insertDelete,
              ),
              ToolbarIcon(
                icon: Icons.format_list_bulleted,
                onTap: () {},
              ),
              ToolbarIcon(
                icon: Icons.title,
                onTap: insertHeading,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ToolbarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  ToolbarIcon({this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Icon(icon, size: 30.0),
      onTap: onTap,
    );
  }
}
