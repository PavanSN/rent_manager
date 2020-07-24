import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/PhoneNumberVerification.dart';
import 'package:home_manager/Models/SignIn.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SettingsBody(),
    );
  }
}

class SettingsBody extends StatelessWidget {
  TextEditingController upiIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        SizedBox(height: 20),
        ListTile(
          onTap: () {
            bottomSheet(
                context, PhoneNumVerificationUI(), 'Update Phone Number');
          },
          leading: Icon(
            Icons.call,
            color: Colors.green,
          ),
          title: Text('Update Phone'),
        ),
        ListTile(
          onTap: () {
            bottomSheet(context, LogoutConfirmation(), 'Are you sure..?');
          },
          leading: Icon(
            Icons.exit_to_app,
            color: Colors.red,
          ),
          title: Text('Logout'),
        ),
        ListTile(
          leading: Icon(Icons.payment),
          title: Text('Update UPI'),
          onTap: () {
            bottomSheet(
                context,
                CustomTextField(
                  enabled: true,
                  hintText: "UPI ID",
                  onSubmitted: (upiId) {
                    if (upiId.toString().contains('@')) {
                      updateDoc({'upiId': upiId},
                          'users/${Injector.get<UserDetails>().uid}');
                      BotToast.showSimpleNotification(
                          title: 'UPI Updated successfully');
                      Navigator.pop(context);
                    } else
                      BotToast.showSimpleNotification(title: 'Invalid UPI ID');
                  },
                ),
                'Update UPI');
          },
        )
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
