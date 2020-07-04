import 'package:flutter/material.dart';

import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/Models/SignIn.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SettingsBody(),
    );
  }
}

class SettingsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        ListTile(
          onTap: () =>
              bottomSheet(context, LogoutConfirmation(), 'Are you sure..?'),
          leading: Icon(
            Icons.exit_to_app,
            color: Colors.red,
          ),
          title: Text('Logout'),
        ),
      ],
    );
  }
}

class LogoutConfirmation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          child: Text('Logout'),
          color: Colors.red,
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
            SignIn().signOut();
          },
        ),
        RaisedButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.green,
          child: Text('Go back..'),
        )
      ],
    );
  }
}
