import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/MonthlyPaymentsContainer.dart';
import 'package:home_manager/CommonFiles/PhoneSIgnInPage.dart';
import 'package:home_manager/CommonFiles/ProfileUi.dart';
import 'package:home_manager/CommonFiles/Settings.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:line_icons/line_icons.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import '../CommonFiles/CommonWidgetsAndData.dart';
import 'package:share/share.dart';

class Tenant extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
  Firestore.instance
      .document('users/${Injector.get<UserDetails>().uid}')
      .get()
      .then((value) {
    value.data['phoneNum'] != null
        ? bottomSheet(context, Container(), '')
        : bottomSheet(context, PhoneNumVerificationUI(), '');
  });
}

//========================== Action Buttons ==================================//

List<Widget> _actions(context) => [
      IconButton(
        icon: Icon(Icons.share),
        onPressed: () => Share.share(
          'Now you can pay and manage rent using this free app https://play.google.com/store/apps/details?id=com.pavansn.rent_manager',
        ),
      ),
      IconButton(
        icon: Icon(
          LineIcons.wrench,
        ),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => Settings())),
      )
    ];

//========================== Action Buttons ==================================//

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        ProfileUi(),
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
                print(e);
                return Text('Loading..');
              }
            },
          ),
        )
      ],
    );
  }
}
