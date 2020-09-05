import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'BuildingImageUpdater.dart';
import 'TenantList.dart';

class BuildingsCard extends StatelessWidget {
  final String buildingName;
  final AsyncSnapshot<DocumentSnapshot> myDocSnap;
  final bool isOffline;

  BuildingsCard({this.buildingName, this.myDocSnap, this.isOffline});

  @override
  Widget build(BuildContext context) {
    var buildingPhoto =
        myDocSnap.data.data()['buildingsPhoto'][buildingName] ?? null;
    return Card(
      elevation: 15,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Container(
        child: ListTile(
          onLongPress: () => deleteBuilding(context, isOffline, buildingName),
          onTap: () {
            bottomSheet(
              context,
              Column(
                children: <Widget>[
                  TenantList(
                    buildingName: buildingName,
                    isOffline: isOffline,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.add,
                        ),
                        onPressed: () => bottomSheet(
                          context,
                          AddTenant(
                            buildingName: buildingName,
                            isOffline: isOffline,
                          ),
                          'Add Tenant',
                        ),
                      )
                    ],
                  ),
                ],
              ),
              'Tenants in building : $buildingName',
            );
          },
          title: Text(buildingName),
          subtitle:
              Text('Tenants : ${myDocSnap.data.data()[buildingName].length}'),
          trailing: RaisedButton(
            color: Colors.green,
            child: Text('Add Tenant'),
            onPressed: () => bottomSheet(
              context,
              AddTenant(
                buildingName: buildingName,
                isOffline: isOffline,
              ),
              'Add Tenant',
            ),
          ),
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ImageCapture(buildingName: buildingName);
              }));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                (buildingPhoto != null)
                    ? buildingPhoto
                    : 'https://img.icons8.com/bubbles/50/000000/city.png',
                fit: BoxFit.cover,
                height: 50,
                width: 50,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

deleteBuilding(context, isOffline, buildingName) {
  bottomSheet(
      context,
      Column(
        children: <Widget>[
          Text(
            'All the tenant data and building data will be removed and cannot be recovered...',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          RaisedButton(
            child: Text('Delete Now'),
            color: Colors.red,
            onPressed: () async {
              if (!isOffline) {
                List buildings;
                await myDoc
                    .get()
                    .then((value) => buildings = value.data()[buildingName]);
                buildings.forEach((tenantUid) {
                  updateDoc({'homeId': null, 'rent': null}, 'users/$tenantUid');
                });
                myDoc.update({
                  'buildings': FieldValue.arrayRemove([buildingName]),
                  'userCount': FieldValue.arrayRemove(buildings),
                  buildingName: FieldValue.delete(),
                }).then((value) {
                  FirebaseStorage.instance
                      .ref()
                      .child(
                          'profiles/${FirebaseAuth.instance.currentUser.uid}$buildingName.png')
                      .delete();
                });
              } else {
                List buildings;
                await myDoc
                    .get()
                    .then((value) => buildings = value.data()[buildingName]);
                buildings.forEach((tenantUid) {
                  myDoc.collection('offline').doc(tenantUid).delete();
                });
                myDoc.update({
                  'offlineBuildings': FieldValue.arrayRemove([buildingName]),
                  'offlineTenants': FieldValue.arrayRemove(buildings),
                  buildingName: FieldValue.delete(),
                });
                FirebaseStorage.instance
                    .ref()
                    .child(
                        'profiles/${FirebaseAuth.instance.currentUser.uid}$buildingName.png')
                    .delete();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      'Warning');
}

PhoneNumber phoneNo;

class AddTenant extends StatelessWidget {
  final buildingName;
  final isOffline;

  AddTenant({this.buildingName, this.isOffline});

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController rentController = TextEditingController();
    return !isOffline
        ? Padding(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: InternationalPhoneNumberInput(
        initialValue: PhoneNumber(
          phoneNumber: '',
          dialCode: '+91',
          isoCode: 'IN',
        ),
        hintText: "Phone Number",
        onInputChanged: (phone) => phoneNo = phone,
        onSubmit: () => addTenantOnline(context, buildingName),
      ),
    )
        : Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter tenant name',
              labelText: 'Name',
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: TextFormField(
            controller: rentController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter tenant rent',
              labelText: 'Rent',
            ),
            keyboardType: TextInputType.numberWithOptions(),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: InternationalPhoneNumberInput(
            hintText: 'Phone Number',
            initialValue: PhoneNumber(isoCode: 'IN'),
            onInputChanged: (phoneNum) => phoneNo = phoneNum,
            onSubmit: () {},
          ),
        ),
        MaterialButton(
          color: Colors.deepOrange,
          child: Text("Save"),
          onPressed: () {
            if (nameController.text.isEmpty ||
                rentController.text.isEmpty) {
              Fluttertoast.showToast(
                  msg: 'Please fill up the empty fields');
            } else {
              myDoc.collection('offline').add({
                'name': nameController.text,
                'phoneNum': phoneNo.phoneNumber,
                'rent': rentController.text,
                'accCreated': DateTime
                    .now()
                    .year
              }).then((value) {
                myDoc.update({
                  'offlineTenants': FieldValue.arrayUnion([value.id]),
                  buildingName: FieldValue.arrayUnion([value.id])
                });
                value
                    .collection('payments')
                    .doc('payments')
                    .set({'docExist': true});
              });
              Navigator.pop(context);
            }
          },
        )
      ],
    );
  }
}

addTenantOnline(context, buildingName) {
  FirebaseFirestore.instance
      .collection('users')
      .where('phoneNum', isEqualTo: phoneNo.phoneNumber)
      .get()
      .then((docs) {
    if (docs.docs.length == 0) {
      Fluttertoast.showToast(msg: 'Tenant\'s phone isn\'t registered');
    } else if (docs.docs.elementAt(0).data()['homeId'] != null) {
      Fluttertoast.showToast(msg: 'Tenant is already under a owner');
    } else if (docs.docs.first.data()['uid'] ==
        FirebaseAuth.instance.currentUser.uid) {
      Fluttertoast.showToast(msg: 'You cannot enter your phone number');
    } else if (docs.docs.length != 0) {
      var tenantDoc = docs.docs
          .elementAt(0)
          .reference;
      tenantDoc.update({
        'homeId': FirebaseAuth.instance.currentUser.uid,
      });
      myDoc.update({
        buildingName: FieldValue.arrayUnion([tenantDoc.id]),
        'userCount': FieldValue.arrayUnion([tenantDoc.id]),
        'buildingsPhoto': {buildingName: null}
      });
      Fluttertoast.showToast(msg: 'Waiting for owner to accept your request');
      Navigator.pop(context);
    }
  });
}
