import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/MonthlyPaymentsContainer.dart';
import 'package:home_manager/CommonFiles/PhoneNumberVerification.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../CommonFiles/CommonWidgetsAndData.dart';

class Tenant extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        myDoc.get().catchError((e) {
          setState(() {});
        });
        return Scaffold(
          appBar: AppBar(
            actions: share(),
            title: Text(
              'Tenant',
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: true,
          ),
          body: StreamBuilder(
            stream: myDoc.snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> myDocSnap) {
              return Body(myDocSnap: myDocSnap);
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: StreamBuilder(
            stream: myDoc.snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> myDocSnap) {
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
  final AsyncSnapshot<DocumentSnapshot> myDocSnap;

  const FloatingBtnFcn({this.myDocSnap});

  @override
  Widget build(BuildContext context) {
    try {
      return FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        child: myDocSnap.data.data()['homeId'] != null
            ? Icon(Icons.call)
            : Icon(Icons.add),
        onPressed: () {
          if (myDocSnap.data.data()['homeId'] == null) {
            String tenantPhone = myDocSnap.data.data()['phoneNum'];
            tenantPhone == null
                ? bottomSheet(
                context, PhoneNumVerificationUI(), 'Register your number')
                : bottomSheet(
                    context,
                    AddOwner(
                      myDocSnap: myDocSnap,
                    ),
                    'Enter Owner Phone Number');
          } else {
            futureDoc('users/${myDocSnap.data.data()['homeId']}')
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
  final AsyncSnapshot<DocumentSnapshot> myDocSnap;

  Body({this.myDocSnap});

  @override
  Widget build(BuildContext context) {
    try {
      Fluttertoast.showToast(msg: 'Welcome Tenant...');
      return MonthlyPayments(
        tenantSnap: myDocSnap,
        isTenant: true,
        rentAmnt: int.parse(myDocSnap.data.data()['rent']),
        isOffline: false,
      );
    } catch (e) {
      if (myDocSnap.connectionState == ConnectionState.active) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CheckFor(
                checkFor: myDocSnap.data.data()['phoneNum'] != null,
                text: 'Your phone number registered : ',
              ),
              CheckFor(
                checkFor: myDocSnap.data.data()['homeId'] != null,
                text: 'Added owner / Owner accepted your request : ',
              )
            ],
          ),
        );
      } else {
        return Container();
      }
    }
  }
}

class CheckFor extends StatelessWidget {
  final bool checkFor;
  final String text;

  CheckFor({this.checkFor, this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          text,
          style: Theme
              .of(context)
              .textTheme
              .caption,
        ),
        checkFor
            ? Icon(
          Icons.done,
          color: Colors.green,
        )
            : Icon(
          Icons.close,
          color: Colors.red,
        ),
      ],
    );
  }
}

PhoneNumber phoneNo;

class AddOwner extends StatelessWidget {
  final AsyncSnapshot<DocumentSnapshot> myDocSnap;

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
            if (FirebaseAuth.instance.currentUser.phoneNumber ==
                phoneNo.phoneNumber) {
              Fluttertoast.showToast(msg: 'You cannot enter your phone number');
              Navigator.of(context).pop();
            } else if (docs.docs.length == 0) {
              Fluttertoast.showToast(msg: 'Owner\'s phone isn\'t registered');
            } else {
              var doc = docs.docs.first.reference;
              doc.update({
                'requests': FieldValue.arrayUnion(
                    [FirebaseAuth.instance.currentUser.uid])
              });
              Fluttertoast.showToast(
                  msg: 'Waiting for owner to accept your request');
              Navigator.pop(context);
            }
          });
        },
      ),
    );
  }
}
