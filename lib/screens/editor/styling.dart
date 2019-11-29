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
    return SingleChildScrollView(
      child: Wrap(
        children: <Widget>[
          ToolbarIcon(
            icon: Icons.format_bold,
            onTap: insertBold,
            description: 'Bold',
          ),
          ToolbarIcon(
            icon: Icons.format_italic,
            onTap: insertItalic,
            description: 'Italic',
          ),
          ToolbarIcon(
            icon: Icons.format_underlined,
            onTap: insertUnderline,
            description: 'Underline',
          ),
          ToolbarIcon(
            icon: Icons.format_quote,
            onTap: insertQuote,
            description: 'Quote',
          ),
          ToolbarIcon(
            icon: Icons.format_strikethrough,
            onTap: insertDelete,
            description: 'Delete',
          ),
          ToolbarIcon(
            icon: Icons.format_list_bulleted,
            onTap: () {},
            description: 'List',
          ),
          ToolbarIcon(
            icon: Icons.title,
            onTap: insertHeading,
            description: 'Heading',
          ),
        ],
      ),
    );
  }
}

class ToolbarIcon extends StatelessWidget {
  final IconData icon;
  final String description;
  final VoidCallback onTap;

  ToolbarIcon({
    @required this.icon,
    @required this.description,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      child: Container(
        width: 68.0,
        height: 68.0,
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 30.0),
            Text(
              description,
              style: Theme.of(context).textTheme.caption,
            )
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
