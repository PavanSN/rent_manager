import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_manager/CommonFiles/LoadingScreen.dart';
import 'package:home_manager/CommonFiles/TenantOrOwnerPage.dart';
import 'package:home_manager/Models/TenantYearPressed.dart';
import 'package:home_manager/Tenant/TenantHomePage.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'CommonFiles/CommonWidgetsAndData.dart';
import 'CommonFiles/SignInPage.dart';
import 'Models/UserDetails.dart';
import 'Owner/OwnerHomePage.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  runApp(RentManager());
}

class RentManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        Inject(() => UserDetails()),
        Inject(() => TenantYearPressed()),
      ],
      builder: (context) {
        return MaterialApp(
          theme: theme,
          home: StreamBuilder(
            stream: FirebaseAuth.instance.onAuthStateChanged,
            builder: (context, user) {
              return user.hasData ? CheckIfTenant() : SignInPage();
            },
          ),
        );
      },
    );
  }
}

class CheckIfTenant extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          futureDoc('users/${Injector.get<UserDetails>(context: context).uid}'),
      builder: (context, userDoc) {
        try {
          return userDoc.data['isTenant'] ? Tenant() : Owner();
        } catch (e) {
          if (userDoc.hasData) return TenantOrOwner();
        }
        return LoadingScreen();
      },
    );
  }
}
