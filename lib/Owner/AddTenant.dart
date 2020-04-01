import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:states_rebuilder/states_rebuilder.dart';

TextEditingController buildingNameController = TextEditingController();
TextEditingController rentForTenantController = TextEditingController();
TextEditingController upiIdController = TextEditingController();
TextEditingController phoneNumController = TextEditingController();
TextEditingController UIDController = TextEditingController();

addTenant(context, upiId) {
  upiIdController.text = upiId;
  bottomSheet(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextInput(
          labelText: 'Enter your building name (Case Sensitive)',
          controller: buildingNameController,
        ),
        TextInput(
          keyboardType: TextInputType.numberWithOptions(
            signed: true,
          ),
          labelText: 'Rent to be given by the tenant',
          controller: rentForTenantController,
        ),
        TextInput(
          labelText: 'Enter your UPI ID',
          controller: upiIdController,
        ),
        TextInput(
          labelText: 'Enter tenant phone Num',
          controller: phoneNumController,
          keyboardType: TextInputType.numberWithOptions(
            signed: true,
          ),
        ),
        TextInput(
          labelText: 'Tenant UID (Enter UID / Use Camera)',
          controller: UIDController,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              color: Colors.green,
              child: Text('Use Camera'),
              onPressed: () => addTenantToBuildingUsingCam(context),
            ),
            RaisedButton(
              color: Colors.red,
              child: Text('Proceed'),
              onPressed: () => addTenantToBuildingUsingUID(context),
            ),
          ],
        )
      ],
    ),
    'Name of the building',
  );
}

class TextInput extends StatelessWidget {
  final controller;
  final labelText;
  final keyboardType;

  TextInput({this.labelText, this.controller, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        keyboardType: keyboardType,
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: labelText,
        ),
      ),
    );
  }
}

String excludedWords =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#\$%^&*()_+-/*';

addTenantToBuildingUsingCam(BuildContext context) async {
  if (rentForTenantController.text.isEmpty ||
      buildingNameController.text.isEmpty ||
      upiIdController.text.isEmpty ||
      rentForTenantController.text.contains(excludedWords) ||
      phoneNumController.text.isEmpty ||
      phoneNumController.text.contains(excludedWords) ||
      !upiIdController.text.contains('@')) {
    Fluttertoast.showToast(
        msg: 'Please fill up the fields with appropriate details');
  } else if (!upiIdController.text.contains('@')) {
    Fluttertoast.showToast(msg: 'Please enter a valid UPI ID');
  } else {
    String tenantUid = await scanner.scan();
    Firestore.instance.document('users/$tenantUid').updateData(
        {'homeId': Injector
            .get<UserDetails>(context: context)
            .uid}).then((_) {
      Firestore.instance
          .document('users/${Injector
          .get<UserDetails>(context: context)
          .uid}')
          .updateData({
        'buildings': FieldValue.arrayUnion([buildingNameController.text]),
        buildingNameController.text: FieldValue.arrayUnion(
            [Firestore.instance.document('users/$tenantUid')]),
        'upiId': upiIdController.text
      }).then((_) {
        Firestore.instance
            .document('users/$tenantUid/payments/payments')
            .setData({});
      }).then((_) {
        Firestore.instance.document('users/$tenantUid').updateData({
          'rent': rentForTenantController.text,
          'phoneNum': phoneNumController.text
        });
      });
    }).then((_) {
      updateDoc({
        'userCount': FieldValue.arrayUnion([tenantUid])
      }, 'users/${Injector
          .get<UserDetails>(context: context)
          .uid}');
      Navigator.of(context).pop();
    });
  }
}

addTenantToBuildingUsingUID(BuildContext context) async {
  if (rentForTenantController.text.isEmpty ||
      buildingNameController.text.isEmpty ||
      upiIdController.text.isEmpty ||
      rentForTenantController.text.contains(excludedWords) ||
      phoneNumController.text.isEmpty ||
      phoneNumController.text.contains(excludedWords) ||
      !upiIdController.text.contains('@') ||
      UIDController.text.isEmpty) {
    Fluttertoast.showToast(
        msg: 'Please fill up the fields with appropriate details');
  } else if (!upiIdController.text.contains('@')) {
    Fluttertoast.showToast(msg: 'Please enter a valid UPI ID');
  } else {
    String tenantUid = UIDController.text;
    try {
      Firestore.instance.document('users/$tenantUid').updateData({
        'homeId': Injector
            .get<UserDetails>(context: context)
            .uid
      }).then((_) {
        Firestore.instance
            .document(
            'users/${Injector
                .get<UserDetails>(context: context)
                .uid}')
            .updateData({
          'buildings': FieldValue.arrayUnion([buildingNameController.text]),
          buildingNameController.text: FieldValue.arrayUnion(
              [Firestore.instance.document('users/$tenantUid')]),
          'upiId': upiIdController.text
        }).then((_) {
          Firestore.instance
              .document('users/$tenantUid/payments/payments')
              .setData({});
        }).then((_) {
          Firestore.instance.document('users/$tenantUid').updateData({
            'rent': rentForTenantController.text,
            'phoneNum': phoneNumController.text
          });
        });
      }).then((_) {
        updateDoc({
          'userCount': FieldValue.arrayUnion([tenantUid])
        }, 'users/${Injector
            .get<UserDetails>(context: context)
            .uid}');
        Navigator.of(context).pop();
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e);
    }
  }
}
