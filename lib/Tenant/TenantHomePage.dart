import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/MonthlyPaymentsContainer.dart';
import 'package:home_manager/CommonFiles/ProfileUi.dart';
import 'package:home_manager/CommonFiles/Settings.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:line_icons/line_icons.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../CommonFiles/CommonWidgetsAndData.dart';
import 'SelfQRCode.dart';

class Tenant extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: _actions(context),
        centerTitle: true,
        leading: qrButton(context),
      ),
      body: Body(),
    );
  }
}

//========================== Action Buttons ==================================//

List<Widget> _actions(context) => [
      IconButton(
        icon: Icon(
          Icons.info,
          color: Colors.grey,
        ),
        onPressed: () {
          bottomSheet(
              context,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "If already paid contact your owner and send transaction details..",
                  textAlign: TextAlign.center,
                ),
              ),
              "Already Paid..?");
        },
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

//================== Tenant qr code Button with route ===========================//

qrButton(context) {
  return IconButton(
    icon: Hero(
      tag: 'qrCode',
      child: Icon(
        LineIcons.qrcode,
      ),
    ),
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelfQRCode(),
      ),
    ),
  );
}

//================== Tenant qr code Button with route ===========================//

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        ProfileUi(
          isOwner: false,
        ),
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
                  isTenant: true,
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
