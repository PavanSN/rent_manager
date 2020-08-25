import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/MonthlyPaymentsContainer.dart';
import 'package:home_manager/CommonFiles/PhoneNumberVerification.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:share/share.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:url_launcher/url_launcher.dart';

import '../CommonFiles/CommonWidgetsAndData.dart';

class Tenant extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        myDoc().get().catchError((e) {
          setState(() {});
        });
        return Scaffold(
          body: StreamBuilder(
            stream: myDoc().snapshots(),
            builder: (context, myDocSnap) {
              return Body(myDocSnap: myDocSnap);
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: StreamBuilder(
            stream: myDoc().snapshots(),
            builder: (context, myDocSnap) {
              return FloatingBtnFcn(
                myDocSnap: myDocSnap,
              );
            },
          ),
        );
      },
    );
  }
}

class FloatingBtnFcn extends StatelessWidget {
  final myDocSnap;

  const FloatingBtnFcn({this.myDocSnap});

  @override
  Widget build(BuildContext context) {
    try {
      return FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        child: myDocSnap.data['homeId'] != null
            ? Icon(Icons.call)
            : Icon(Icons.add),
        onPressed: () {
          if (myDocSnap.data['homeId'] == null) {
            String tenantPhone = myDocSnap.data['phoneNum'];
            tenantPhone == null
                ? bottomSheet(
                    context, PhoneNumVerificationUI(), 'Verify Your Mobile')
                : bottomSheet(
                    context,
                    AddOwner(
                      myDocSnap: myDocSnap,
                    ),
                    'Enter Owner Phone Number');
          } else {
            futureDoc('users/${myDocSnap.data['homeId']}')
                .then((value) => launch('tel:${value.data()['phoneNum']}'));
          }
        },
      );
    } catch (e) {
      return Container();
    }
  }
}

share() {
  return [
    IconButton(
      icon: Icon(Icons.share),
      onPressed: () {
        Share.share(
            'Pay rent and get rent from tenants easily with on click and log the payments just click https://play.google.com/store/apps/details?id=com.pavansn.rent_manager');
      },
    ),
  ];
}

class Body extends StatelessWidget {
  final myDocSnap;

  const Body({this.myDocSnap});

  @override
  Widget build(BuildContext context) {
    try {
      return MonthlyPayments(
        tenantSnap: myDocSnap,
        isTenant: true,
        rentAmnt: int.parse(myDocSnap.data['rent']),
        isOffline: false,
      );
    } catch (e) {
      print(e);
      return Container();
    }
  }
}

PhoneNumber phoneNo;

class AddOwner extends StatelessWidget {
  final myDocSnap;

  AddOwner({this.myDocSnap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: InternationalPhoneNumberInput(
        initialValue: PhoneNumber(
          phoneNumber: '',
          dialCode: '+91',
          isoCode: 'IN',
        ),
        hintText: "Phone Number",
        onInputChanged: (phone) => phoneNo = phone,
        onSubmit: () {
          FirebaseFirestore.instance
              .collection('users')
              .where('phoneNum', isEqualTo: phoneNo.phoneNumber)
              .get()
              .then((docs) {
            if (docs.docs.first.data()['uid'] ==
                Injector.get<UserDetails>().uid) {
              BotToast.showSimpleNotification(
                  title: 'You cannot enter your phone number');
              Navigator.of(context).pop();
            } else if (docs.docs.length == 0) {
              BotToast.showSimpleNotification(
                  title: 'Owner\'s phone isn\'t registered');
            } else {
              var doc = docs.docs.first.reference;
              doc.update({
                'requests':
                    FieldValue.arrayUnion([Injector.get<UserDetails>().uid])
              });
              BotToast.showSimpleNotification(
                  title: 'Waiting for owner to accept your request');
              Navigator.pop(context);
            }
          });
        },
      ),
    );
  }
}
