import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LicensePage extends StatelessWidget {
  const LicensePage({
    Key key,
  }) : super(key: key);

  Future<List<Widget>> _getLicenses() async {
    List<Widget> licenses = [];
    await for (LicenseEntry license in LicenseRegistry.licenses) {
      licenses.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 18.0),
        child: Text('🍀‬', textAlign: TextAlign.center),
      ));
      licenses.add(
        Text(
          license.packages.join(', '),
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );
      licenses.add(const Divider());
      for (LicenseParagraph paragraph in license.paragraphs) {
        if (paragraph.indent == LicenseParagraph.centeredIndent) {
          licenses.add(Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              paragraph.text,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ));
        } else {
          assert(paragraph.indent >= 0);
          licenses.add(
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: 8.0,
                start: 16.0 * paragraph.indent,
              ),
              child: Text(paragraph.text),
            ),
          );
        }
      }
    }
    return licenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        title: Text(
          'Licenses',
          style: Theme.of(context).textTheme.body2,
        ),
        titleSpacing: 0.0,
        backgroundColor: Theme.of(context).cardColor,
      ),
      body: Localizations.override(
        locale: const Locale('en', 'US'),
        context: context,
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.caption,
          child: SafeArea(
            bottom: false,
            child: FutureBuilder<List<Widget>>(
              future: _getLicenses(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 12.0,
                    ),
                    children: snapshot.data,
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
