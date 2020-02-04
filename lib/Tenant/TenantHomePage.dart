import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/ProfileUi.dart';
import 'package:home_manager/CommonFiles/Settings.dart';
import 'package:home_manager/Models/TabPressed.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:line_icons/line_icons.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../CommonFiles/CommonWidgetsAndData.dart';
import '../CommonFiles/LoadingScreen.dart';
import 'MonthsWithPaymentTile.dart';
import 'Notice.dart';
import 'SelfQRCode.dart';

class Tenant extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: _actions(context),
        centerTitle: true,
        leading: IconButton(
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
        ),
      ),
      body: _Body(),
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

class _Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        ProfileUi(),
        Expanded(
          child: FutureBuilder(
            future: futureDoc('users/${Injector.get<UserDetails>().uid}'),
            builder: (context, userDoc) {
              try{
                return MonthlyPaymentsVisibility(
                  didTenantGetHome: userDoc.data['homeId'] != null,
                  tenantDoc: userDoc,
                );
              }catch(e){
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

class MonthlyPaymentsVisibility extends StatelessWidget {
  final bool didTenantGetHome;
  final AsyncSnapshot tenantDoc;

  MonthlyPaymentsVisibility({this.didTenantGetHome, this.tenantDoc});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: didTenantGetHome,
      replacement: Center(
        child: Text(
          'You need to tap on the qr button (Top Left) in order to register you as a tenant',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Tabs(
              accCreated: tenantDoc.data['accCreated'],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          PayTile(
            month: DateTime.now().month,
            year: DateTime.now().year,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          StateBuilder(
            models: [Injector.get<TabPressed>()],
            builder: (context, _) {
              return Expanded(
                flex: 8,
                child: MonthsWithPaymentTile(
                  year: Injector.get<TabPressed>().yearPressed ??
                      DateTime.now().year,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class Tabs extends StatelessWidget {
  final int accCreated;

  Tabs({this.accCreated});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: getTabs(accCreated).length - 1,
      length: getTabs(accCreated).length,
      child: TabBar(
        onTap: (index) =>
            Injector.get<TabPressed>().yearTapped(accCreated + index),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.red,
        indicatorColor: Colors.red,
        unselectedLabelColor: Color(0xff5f6368),
        isScrollable: true,
        tabs: getTabs(accCreated),
      ),
    );
  }
}

List<Tab> getTabs(int accCreated) {
  var thisYear = DateTime.now().year;
  List<Tab> tabs = [];

  if (accCreated == thisYear) {
    return [
      Tab(
        text: thisYear.toString(),
      )
    ];
  } else if (accCreated < thisYear) {
    int yearDifference = thisYear - accCreated;
    for (int i = 0; i <= yearDifference; i++) {
      tabs.add(Tab(
        text: (accCreated + i).toString(),
      ));
    }
    return tabs;
  } else
    return [
      Tab(
        text: 'You need to be a tenant in the house',
      )
    ];
}
