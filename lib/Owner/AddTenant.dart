import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:states_rebuilder/states_rebuilder.dart';

TextEditingController buildingNameController = TextEditingController();
TextEditingController rentForTenant = TextEditingController();

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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            controller: rentForTenant,
            keyboardType: TextInputType.numberWithOptions(),
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: 'Rent to be given by the tenant',
            ),
          ),
        ),
        RaisedButton(
          color: Colors.red,
          child: Text('Proceed'),
          onPressed: () => addTenantToBuilding(context),
        ),
      ],
    ),
    'Name of the building',
  );
}

addTenantToBuilding(BuildContext context) async {
  if (rentForTenant.text.isEmpty || buildingNameController.text.isEmpty) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Please fill up the fields')));
  } else {
    String tenantUid = await scanner.scan();
    Firestore.instance
        .document('users/$tenantUid')
        .updateData({'homeId': Injector
        .get<UserDetails>()
        .uid}).then((_) {
      Firestore.instance
          .document('users/${Injector
          .get<UserDetails>()
          .uid}')
          .updateData({
        'buildings': FieldValue.arrayUnion([buildingNameController.text]),
        buildingNameController.text: FieldValue.arrayUnion(
            [Firestore.instance.document('users/$tenantUid')])
      }).then((_) {
        Firestore.instance
            .document('users/$tenantUid/payments/${DateTime
            .now()
            .year}')
            .updateData({});
      }).then((_) {
        Firestore.instance.document('users/$tenantUid').updateData({
          'rent': rentForTenant.text,
        });
      });
    }).then((_) {
      Navigator.of(context).pop();
    });
  }
}
