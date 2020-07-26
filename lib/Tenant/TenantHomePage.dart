import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/MonthlyPaymentsContainer.dart';
import 'package:home_manager/CommonFiles/PhoneNumberVerification.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../CommonFiles/CommonWidgetsAndData.dart';

class Tenant extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String homeId;
    myDoc().get().then((value) => homeId = value.data['homeId']);
    BotToast.showSimpleNotification(title: 'Welcome Tenant');
    return Scaffold(
      body: Body(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          if (homeId == null) {
            String phoneNum = Injector.get<UserDetails>().phoneNum;
            phoneNum == '' || phoneNum == null
                ? bottomSheet(
                    context, PhoneNumVerificationUI(), 'Verify Your Mobile')
                : bottomSheet(context, AddOwner(), 'Enter Owner Phone Number');
          } else
            BotToast.showSimpleNotification(title: 'You already have an owner');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: StreamBuilder(
            stream: myDoc().snapshots(),
            builder: (context, myDoc) {
              try {
                if (myDoc.data['homeId'] != null) {
                  return MonthlyPayments(
                    myDocSnap: myDoc,
                  );
                } else {
                  return Container();
                }
              } catch (e) {
                return Container();
              }
            },
          ),
        )
      ],
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
