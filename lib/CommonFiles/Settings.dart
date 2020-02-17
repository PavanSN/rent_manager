import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getflutter/components/list_tile/gf_list_tile.dart';
import 'package:getflutter/getflutter.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/Models/SignIn.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:home_manager/Owner/AddTenant.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

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
        GestureDetector(
          onTap: () {
            TextEditingController phoneNum = TextEditingController();
            bottomSheet(
              context,
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextInput(
                    labelText: 'Your phone number',
                    controller: phoneNum,
                    keyboardType: TextInputType.numberWithOptions(),
                  ),
                  RaisedButton(
                    color: Colors.red,
                    child: Text('Save'),
                    onPressed: () =>
                        Firestore.instance
                            .document('users/${Injector
                            .get<UserDetails>()
                            .uid}')
                            .updateData(
                          {
                            'phoneNum': phoneNum.text,
                          },
                        ).then((_) {
                          Fluttertoast.showToast(msg: 'Phone number saved');
                          Navigator.pop(context);
                        }),
                  ),
                ],
              ),
              'Update your phone number',
            );
          },
          child: GFListTile(
            title: Text('Mobile Number'),
            color: Colors.white,
            avatar: Icon(
              Icons.smartphone,
              color: Colors.green,
            ),
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
