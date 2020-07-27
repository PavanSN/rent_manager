import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/MonthlyPaymentsContainer.dart';
import 'package:home_manager/CommonFiles/PhoneNumberVerification.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:url_launcher/url_launcher.dart';

import '../CommonFiles/CommonWidgetsAndData.dart';

String homeId;

class Tenant extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    myDoc().get().then((value) => homeId = value.data['homeId']);
    BotToast.showSimpleNotification(title: 'Welcome Tenant');
    return Scaffold(
      body: SafeArea(
        child: Body(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: homeId == null
          ? FloatingActionButton(
              tooltip: 'Call Owner',
              backgroundColor: Colors.deepPurple,
              onPressed: () {
                String phoneNum = Injector.get<UserDetails>().phoneNum;
                phoneNum == '' || phoneNum == null
                    ? bottomSheet(
                        context, PhoneNumVerificationUI(), 'Verify Your Mobile')
                    : bottomSheet(
                        context, AddOwner(), 'Enter Owner Phone Number');
              },
              child: Icon(Icons.add),
            )
          : FloatingActionButton(
              backgroundColor: Colors.green,
              child: Icon(
                Icons.call,
                color: Colors.white,
              ),
              onPressed: () {
                Firestore.instance.document('users/$homeId').get().then(
                      (snap) => launch('tel:${snap.data['phoneNum']}'),
                    );
              },
            ),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: myDoc().snapshots(),
      builder: (context, myDoc) {
        try {
          if (myDoc.data['homeId'] != null) {
            return MonthlyPayments(
                tenantSnap: myDoc,
                isTenant: true,
                rentAmnt: myDoc.data['rent']);
          } else {
            return Container();
          }
        } catch (e) {
          return Container();
        }
      },
    );
  }
}

PhoneNumber phoneNo;

class AddOwner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: InternationalPhoneNumberInput(
        initialValue: PhoneNumber(
          phoneNumber: '',
          dialCode: '+91',
          isoCode: 'IN',
        ),
        hintText: "Phone Number",
        onInputChanged: (phone) => phoneNo = phone,
        onSubmit: () {
          if (phoneNo.phoneNumber == Injector.get<UserDetails>().phoneNum) {
            BotToast.showSimpleNotification(
                title: 'You cannot enter your phone number');
            Navigator.of(context).pop();
          } else {
            Firestore.instance
                .collection('users')
                .where('phoneNum', isEqualTo: phoneNo.toString())
                .getDocuments()
                .then((docs) {
              if (docs.documents.length != 0) {
                var doc = docs.documents.elementAt(0).reference;
                doc.updateData({
                  'requests':
                      FieldValue.arrayUnion([Injector.get<UserDetails>().uid])
                });
                BotToast.showSimpleNotification(
                    title: 'Waiting for owner to accept your request');
                Navigator.pop(context);
              } else {
                BotToast.showSimpleNotification(
                    title: 'Owner\'s phone isn\'t registered');
              }
            });
          }
        },
      ),
    );
  }
}
