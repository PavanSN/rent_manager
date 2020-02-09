import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_manager/CommonFiles/LoadingScreen.dart';
import 'package:home_manager/CommonFiles/TenantOrOwnerPage.dart';
import 'package:home_manager/Models/TabPressed.dart';
import 'package:home_manager/Tenant/TenantHomePage.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'CommonFiles/CommonWidgetsAndData.dart';
import 'CommonFiles/LoadingScreen.dart';
import 'CommonFiles/SignInPage.dart';
import 'CommonFiles/TenantOrOwnerPage.dart';
import 'Models/UserDetails.dart';
import 'Owner/OwnerHomePage.dart';
import 'Tenant/TenantHomePage.dart';

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
          home: StreamBuilder(
            stream: FirebaseAuth.instance.onAuthStateChanged,
            builder: (context, user) {
              return user.hasData ? ShowTenantOrOwner() : SignInPage();
            },
          ),
        );
      },
    );
  }
}

class ShowTenantOrOwner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      models: [Injector.get<UserDetails>()],
      builder: (context, _) {
        return StreamBuilder(
          stream: streamDoc('users/${Injector
              .get<UserDetails>()
              .uid}'),
          builder: (context, userDoc) {
            try {
              return userDoc.data['isTenant'] == null
                  ? TenantOrOwner()
                  : CheckTenantOrOwner(userDoc: userDoc);
            } catch (e) {
              return LoadingScreen();
            }
          },
        );
      },
    );
  }
}

class CheckTenantOrOwner extends StatelessWidget {
  final AsyncSnapshot userDoc;

  CheckTenantOrOwner({this.userDoc});

  @override
  Widget build(BuildContext context) {
    return userDoc.data['isTenant'] ? Tenant() : CheckSubscription();
  }
}
