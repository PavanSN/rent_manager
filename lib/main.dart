import 'package:bot_toast/bot_toast.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_manager/CommonFiles/Settings.dart';
import 'package:home_manager/Models/TabPressed.dart';
import 'package:home_manager/Tenant/TenantHomePage.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'CommonFiles/CommonWidgetsAndData.dart';
import 'CommonFiles/GoogleSignInPage.dart';
import 'Models/UserDetails.dart';
import 'Owner/OwnerHomePage.dart';

void main() {
  runApp(RentManager());
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
}

class RentManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        Inject(() => UserDetails()),
        Inject(() => TabPressed()),
      ],
      builder: (context) {
        return MaterialApp(
          theme: theme,
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver()],
          home: StreamBuilder(
            stream: FirebaseAuth.instance.onAuthStateChanged,
            builder: (context, user) {
              return user.hasData ? MainPage() : GoogleSignInPage();
            },
          ),
        );
      },
    );
  }
}

class MainPage extends StatelessWidget {
  List<BubbleBottomBarItem> tabs = [
    BubbleBottomBarItem(
      activeIcon: Icon(Icons.payment),
      backgroundColor: Colors.deepPurple,
      title: Text('Pay Rent'),
      icon: Icon(Icons.payment, color: Colors.grey),
    ),
    BubbleBottomBarItem(
      activeIcon: Icon(Icons.account_balance_wallet),
      backgroundColor: Colors.pink,
      title: Text('Get Rent'),
      icon: Icon(Icons.account_balance_wallet, color: Colors.grey),
    ),
    BubbleBottomBarItem(
      activeIcon: Icon(Icons.settings),
      backgroundColor: Colors.blueGrey,
      title: Text('Settings'),
      icon: Icon(Icons.settings, color: Colors.grey),
    ),
  ];
  List body = [Tenant(), CheckSubscription(), Settings()];
  int currIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          bottomNavigationBar: BubbleBottomBar(
            inkColor: Colors.black,
            items: tabs,
            opacity: 0.2,
            currentIndex: currIndex,
            onTap: (index) => setState(() {
              currIndex = index;
            }),
          ),
          body: body[currIndex],
        );
      },
    );
  }
}
