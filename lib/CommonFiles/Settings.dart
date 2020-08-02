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
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SettingsBody(),
    );
  }
}

TextEditingController upiIdController = TextEditingController();

class SettingsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        UpdatePhoneNumTile(),
        UpdateUpiTile(),
        ListTile(
          onTap: () {
            bottomSheet(context, LogoutConfirmation(), 'Are you sure..?');
          },
          leading: Icon(
            Icons.exit_to_app,
            color: Colors.red,
          ),
          title: Text('Logout'),
        )
      ],
    );
  }
}

class UpdatePhoneNumTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        bottomSheet(context, PhoneNumVerificationUI(), 'Update Phone Number');
      },
      leading: Icon(
        Icons.call,
        color: Colors.green,
      ),
      title: Text('Update Phone'),
    );
  }
}

class UpdateUpiTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.payment),
      title: Text('Update UPI'),
      onTap: () {
        bottomSheet(
            context,
            CustomTextField(
              enabled: true,
              hintText: "Your UPI ID",
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
