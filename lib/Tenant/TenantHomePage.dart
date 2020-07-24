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
    BotToast.showSimpleNotification(title: 'Welcome Tenant');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Body(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          String phoneNum = Injector.get<UserDetails>().phoneNum;
          phoneNum == '' || phoneNum == null
              ? bottomSheet(context, PhoneNumVerificationUI(), 'Verify Mobile')
              : bottomSheet(context, AddOwner(), 'Enter Owner Phone Number');
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
            stream: streamDoc('users/${Injector.get<UserDetails>().uid}'),
            builder: (context, userDoc) {
              try {
                return MonthlyPayments(
                  didTenantGetHome: userDoc.data['homeId'] != null,
                  tenantDoc: userDoc,
                  tenantDocRef: Firestore.instance
                      .document('users/${Injector.get<UserDetails>().uid}'),
                );
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

class AddOwner extends StatelessWidget {
  PhoneNumber phoneNo;

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
      ),
    );
  }
}
