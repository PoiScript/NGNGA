import 'package:flutter/material.dart' hide LicensePage;
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ngnga/localizations.dart';

import 'license.dart';

const authorEmail = 'poiscript@gmail.com';
const sourceUrl = 'https://github.com/PoiScript/NGNGA';
const issuesUrl = 'https://github.com/PoiScript/NGNGA/issues';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            title: Text(
              AppLocalizations.of(context).about,
              style: Theme.of(context).textTheme.body2,
            ),
            titleSpacing: 0.0,
            backgroundColor: Theme.of(context).cardColor,
          ),
          body: ListView(
            children: <Widget>[
              SizedBox(
                height: 150.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/icons/logo.png',
                      width: 72.0,
                      height: 72.0,
                    ),
                    Text('v${snapshot.data.version}'),
                  ],
                ),
              ),
              ListTile(
                title: Text('Author'),
                subtitle: Text(authorEmail),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () => launch('mailto:$authorEmail'),
              ),
              ListTile(
                title: Text('Source Code'),
                subtitle: Text(sourceUrl),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () => launch(sourceUrl),
              ),
              ListTile(
                title: Text('Bug Tracker'),
                subtitle: Text(issuesUrl),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () => launch(issuesUrl),
              ),
              ListTile(
                title: Text('License'),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LicensePage()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
