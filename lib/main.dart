import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_manager/Models/TabPressed.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'CommonFiles/CommonWidgetsAndData.dart';
import 'CommonFiles/SignInPage.dart';
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
          home: StreamBuilder(
            stream: FirebaseAuth.instance.onAuthStateChanged,
            builder: (context, user) {
              return user.hasData ? CheckIfOwner() : SignInPage();
            },
          ),
        );
      },
    );
  }
}