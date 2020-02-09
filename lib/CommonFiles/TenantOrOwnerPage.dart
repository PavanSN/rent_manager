import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/Owner/OwnerHomePage.dart';
import 'package:home_manager/Tenant/TenantHomePage.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../Models/UserDetails.dart';
import 'CommonWidgetsAndData.dart';

class TenantOrOwner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF0545),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          StateBuilder(
            models: [Injector.get<UserDetails>()],
            builder: (context, _) {
              return ChoosingCard(
                titleText: "If you are paying rent...",
                btnText: "Tenant",
                onPressed: () {
                  var data = {'isTenant': true};
                  Firestore.instance
                      .document(
                      'users/${Injector
                          .get<UserDetails>()
                          .uid}/payments/payments')
                      .setData({});
                  updateDoc(data, 'users/${Injector.get<UserDetails>().uid}')
                      .then(
                        (data) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Tenant()));
                    },
                  );
                },
              );
            },
          ),
          StateBuilder(
            models: [Injector.get<UserDetails>()],
            builder: (context, _) {
              return ChoosingCard(
                titleText: "If you are owning the house and rented it...",
                btnText: "Owner",
                onPressed: () {
                  var date = DateTime.now();
                  var expDate = DateTime(date.year, date.month, date.day + 30)
                      .millisecondsSinceEpoch;
                  var data = {
                    'isTenant': false,
                    'homeId': Injector
                        .get<UserDetails>()
                        .uid,
                    'expDate': expDate,
                  };
                  updateDoc(data, 'users/${Injector.get<UserDetails>().uid}')
                      .then(
                        (data) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Owner()));
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

//  ===================================== abstract code below do not touch ==========================================  //

class ChoosingCard extends StatelessWidget {
  final String titleText;
  final String btnText;
  final Function onPressed;

  ChoosingCard({this.titleText, this.btnText, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                titleText,
                style: TextStyle(fontSize: 20),
              ),
              OwnerOrTenantBtn(
                btnText: btnText,
                onPressed: onPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OwnerOrTenantBtn extends StatelessWidget {
  const OwnerOrTenantBtn({
    Key key,
    @required this.btnText,
    @required this.onPressed,
  }) : super(key: key);

  final String btnText;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 10,
      color: Colors.white,
      onPressed: onPressed,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              btnText,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.green,
            )
          ],
        ),
      ),
    );
  }
}

//  ===================================== abstract code below do not touch ==========================================  //
