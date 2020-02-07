import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/MonthlyPaymentsContainer.dart';
import 'package:home_manager/CommonFiles/ProfileUi.dart';
import 'package:home_manager/CommonFiles/Settings.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:line_icons/line_icons.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../CommonFiles/CommonWidgetsAndData.dart';
import '../CommonFiles/LoadingScreen.dart';
import 'Notice.dart';
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
          LineIcons.bell_o,
        ),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => Notice())),
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
  IconButton(
    icon: Hero(
      tag: 'qrCode',
      child: Icon(
        LineIcons.qrcode,
      ),
    ),
    onPressed: () =>
        Navigator.push(
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
          child: FutureBuilder(
            future: futureDoc('users/${Injector.get<UserDetails>().uid}'),
            builder: (context, userDoc) {
              try {
                return MonthlyPayments(
                  didTenantGetHome: userDoc.data['homeId'] != null,
                  tenantDoc: userDoc,
                );
              } catch (e) {
                print(e);
                return LoadingScreen();
              }
            },
          ),
        )
      ],
    );
  }
}

