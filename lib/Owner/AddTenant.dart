import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:states_rebuilder/states_rebuilder.dart';

TextEditingController buildingNameController = TextEditingController();

addTenant(context) {
  bottomSheet(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            controller: buildingNameController,
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: 'Enter your building name (Case sensitive)',
            ),
          ),
        ),
        RaisedButton(
          color: Colors.red,
          child: Text('Proceed'),
          onPressed: () => addTenantToBuilding(),
        ),
      ],
    ),
    'Name of the building',
  );
}

addTenantToBuilding() async {
  String tenantUid = await scanner.scan();
  Firestore.instance
      .document('users/$tenantUid')
      .updateData({'homeId': Injector.get<UserDetails>().uid}).then((data) {
    Firestore.instance
        .document('users/${Injector.get<UserDetails>().uid}')
        .updateData({
      'buildings': FieldValue.arrayUnion([buildingNameController.text]),
      buildingNameController.text: FieldValue.arrayUnion(
          [Firestore.instance.document('users/$tenantUid')])
    });
  });
}
