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
    return StreamBuilder(
      stream:
      streamDoc('users/${Injector
          .get<UserDetails>(context: context)
          .uid}'),
      builder: (context, userDoc) {
        if (userDoc.hasData && !userDoc.hasError) {
          return userDoc.data['isTenant']
              ? Tenant()
              : Owner() ?? TenantOrOwner();
        } else
          return LoadingScreen();
      },
    );
  }
}
