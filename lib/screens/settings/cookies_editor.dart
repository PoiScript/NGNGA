import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:ngnga/store/state.dart';

class EditCookiesPage extends StatefulWidget {
  final List<String> cookies;
  final void Function(List<String>) updateCookies;

  EditCookiesPage({
    @required this.cookies,
    @required this.updateCookies,
  });

  @override
  _EditCookiesPageState createState() => _EditCookiesPageState();
}

final _formKey = GlobalKey<FormState>();

class _EditCookiesPageState extends State<EditCookiesPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> fields = [];

    for (var cookie in widget.cookies) {
      var pair = cookie.split("=");
      fields.add(TextFormField(
        initialValue: pair.first,
        decoration: const InputDecoration(
          labelText: 'Key',
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter cookie key';
          }
          return null;
        },
      ));
      fields.add(TextFormField(
        minLines: 1,
        maxLines: null,
        initialValue: pair.last,
        decoration: const InputDecoration(
          labelText: 'Value',
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter cookie value';
          }
          return null;
        },
      ));
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: Text(
          "Cookies Editor",
          style: Theme.of(context).textTheme.body2,
        ),
        titleSpacing: 0.0,
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Form(
          key: _formKey,
          child: ListView.builder(
            itemBuilder: (context, index) => fields[index],
            itemCount: fields.length,
          ),
        ),
      ),
    );
  }
}

class EditCookiesPageConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(),
      builder: (context, vm) => EditCookiesPage(
        cookies: vm.cookies,
        updateCookies: vm.updateCookies,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  List<String> cookies;
  void Function(List<String>) updateCookies;

  ViewModel();

  ViewModel.build({
    @required this.cookies,
    @required this.updateCookies,
  }) : super(equals: [cookies]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      cookies: state.cookies,
      updateCookies: (map) => {},
    );
  }
}
