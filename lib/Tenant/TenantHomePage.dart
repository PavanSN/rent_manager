import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/MonthlyPaymentsContainer.dart';
import 'package:home_manager/CommonFiles/PhoneNumberVerification.dart';
import 'package:home_manager/CommonFiles/ProfileUi.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../CommonFiles/CommonWidgetsAndData.dart';

class Tenant extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BotToast.showSimpleNotification(title: 'Welcome Tenant');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tenant',
          style: Theme.of(context).textTheme.subtitle1,
        ),
        centerTitle: true,
        actions: _actions(context),
        leading: IconButton(
          icon: Icon(Icons.add),
          onPressed: () => leading(context),
        ),
      ),
      body: Body(),
    );
  }
}

leading(context) {
  String phoneNum = Injector
      .get<UserDetails>()
      .phoneNum;
  print(phoneNum);
  phoneNum == '' || phoneNum == null
      ? bottomSheet(context, PhoneNumVerificationUI(), 'Verify Mobile')
      : bottomSheet(context, Container(), '');
}

List<Widget> _actions(context) => [
  IconButton(
    icon: Icon(Icons.person),
    onPressed: () => bottomSheet(context, ProfileUi(), 'Profile'),
  ),
];

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: StreamBuilder(
            stream: streamDoc('users/${Injector.get<UserDetails>().uid}'),
            builder: (context, userDoc) {
              try {
                return MonthlyPayments(
                  didTenantGetHome: userDoc.data['homeId'] != null,
                  tenantDoc: userDoc,
                  tenantDocRef: Firestore.instance
                      .document('users/${Injector.get<UserDetails>().uid}'),
                );
              } catch (e) {
                return Container();
              }
            },
          ),
        )
      ],
    );
  }
}
