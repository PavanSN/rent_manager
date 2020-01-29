import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getflutter/getflutter.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/Settings.dart';
import 'package:home_manager/Models/TenantYearPressed.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:line_icons/line_icons.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

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
      body: SafeArea(child: _Body()),
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

//========================== Profile Button start ================================//

class _ProfileIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          StateBuilder(
            models: [Injector.get<UserDetails>()],
            builder: (context, _) {
              return Material(
                elevation: 15,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                child: GFAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage:
                      NetworkImage(Injector.get<UserDetails>().photoUrl),
                ),
              );
            },
          ),
          UserName(),
          HomeID(),
        ],
      ),
    );
  }
}

class HomeID extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureDoc('users/${Injector.get<UserDetails>().uid}'),
      builder: (context, userDoc) {
        if (!userDoc.hasData) return Text('Loading');
        return Text(
          'Home ID : ${userDoc.data['homeId']}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        );
      },
    );
  }
}

class UserName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      models: [Injector.get<UserDetails>()],
      builder: (context, _) {
        return Text(
          'Hello, ${Injector.get<UserDetails>().name}',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w300),
        );
      },
    );
  }
}

//========================== Profile Button end ==================================//

class _Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Center(
          child: _ProfileIcon(),
        ),
        Expanded(
          child: FutureBuilder(
            future: futureDoc('users/${Injector.get<UserDetails>().uid}'),
            builder: (context, userDoc) {
              return IfTenantGetHome(
                  didTenantGetHome:
                      userDoc.data['homeId'] == null ? false : true);
            },
          ),
        )
      ],
    );
  }
}

class IfTenantGetHome extends StatelessWidget {
  final bool didTenantGetHome;

  IfTenantGetHome({this.didTenantGetHome});

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
            child: FutureBuilder(
              future: Firestore.instance
                  .document('users/${Injector.get<UserDetails>().uid}')
                  .get(),
              builder: (context, userDoc) {
                if (!userDoc.hasData) return Text('Loading');
                return Tabs(
                  accCreated: userDoc.data['accCreated'],
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          PayTile(
            month: DateTime.now().month,
            year: DateTime.now().year,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          StateBuilder(
            models: [Injector.get<TenantYearPressed>()],
            builder: (context, _) {
              return Expanded(
                flex: 8,
                child: MonthsWithPaymentTile(
                  year: Injector.get<TenantYearPressed>().yearPressed ??
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
            Injector.get<TenantYearPressed>().yearTapped(accCreated + index),
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
