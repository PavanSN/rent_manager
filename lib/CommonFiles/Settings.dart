import 'package:flutter/material.dart';
import 'package:getflutter/components/list_tile/gf_list_tile.dart';
import 'package:getflutter/getflutter.dart';
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
        GestureDetector(
          onTap: () =>
              bottomSheet(context, LogoutConfirmation(), 'Are you sure..?'),
          child: GFListTile(
            color: Colors.white,
            avatar: Icon(
              Icons.exit_to_app,
              color: Colors.red,
            ),
            title: Text('Logout'),
          ),
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
        GFButton(
          text: 'Logout',
          color: Colors.red,
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
            SignIn().signOut();
          },
        ),
        GFButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.green,
          text: 'Go back..',
        )
      ],
    );
  }
}
