import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/MonthlyPaymentsContainer.dart';
import 'package:url_launcher/url_launcher.dart';

class TenantList extends StatelessWidget {
  final String buildingName;
  final rentAmnt;
  final isOffline;

  TenantList({this.buildingName, this.rentAmnt, this.isOffline});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: myDoc.snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
        try {
          List tenantUids = snap.data.data()[buildingName];
          return ListView.builder(
            shrinkWrap: true,
            itemCount: tenantUids.length,
            itemBuilder: (context, index) {
              return TenantTile(
                tenantUid: tenantUids[index],
                buildingName: buildingName,
                isOffline: isOffline,
              );
            },
          );
        } catch (e) {
          return Container();
        }
      },
    );
  }
}

class TenantTile extends StatelessWidget {
  final tenantUid;
  final buildingName;
  final rentAmnt;
  final isOffline;

  const TenantTile(
      {this.tenantUid, this.buildingName, this.rentAmnt, this.isOffline});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: !isOffline
          ? FirebaseFirestore.instance.doc('users/$tenantUid').snapshots()
          : myDoc.collection('offline').doc(tenantUid).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> tenantSnap) {
        try {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Card(
              elevation: 10,
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return MonthlyPayments(
                          tenantSnap: tenantSnap,
                          isTenant: false,
                          isOffline: isOffline,
                          rentAmnt: rentAmnt,
                          offlineTenantUid: tenantUid,
                        );
                      },
                    ),
                  );
                },
                trailing: TenantTileTrailingBtn(
                  tenantSnap: tenantSnap,
                  tenantUid: tenantUid,
                  buildingName: buildingName,
                  isOffline: isOffline,
                ),
                title: Text(tenantSnap.data.data()['name']),
                subtitle: Text('Rent = ${tenantSnap.data.data()['rent']}'),
              ),
            ),
          );
        } catch (e) {
          return Container();
        }
      },
    );
  }
}

class TenantTileTrailingBtn extends StatelessWidget {
  final tenantUid;
  final AsyncSnapshot<DocumentSnapshot> tenantSnap;
  final buildingName;
  final isOffline;

  TenantTileTrailingBtn({
    this.tenantSnap,
    this.tenantUid,
    this.buildingName,
    this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        tenantSnap.data.data()['rent'] == null
            ? Icon(
                Icons.error_outline,
                color: Colors.red,
              )
            : SizedBox(),
        IconButton(
          icon: Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () {
            print(tenantUid);
            return onDelete(
                context, tenantUid, buildingName, tenantSnap, isOffline);
          },
        ),
        IconButton(
          color: Colors.green,
          icon: Icon(Icons.call),
          onPressed: () {
            launch('tel:${tenantSnap.data.data()['phoneNum']}');
          },
        ),
        IconButton(
          color: Colors.blueGrey,
          icon: Icon(Icons.edit),
          onPressed: () {
            TextEditingController rentController = TextEditingController();
            bottomSheet(
                context,
                Column(
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                    MaterialButton(
                      color: Colors.deepOrange,
                      child: Text("Save"),
                      onPressed: () {
                        if (rentController.text.isEmpty) {
                          Fluttertoast.showToast(
                              msg: 'Please fill up the empty fields');
                        } else {
                          isOffline
                              ? myDoc
                                  .collection('offline')
                                  .doc(tenantUid)
                                  .update({
                                  'rent': rentController.text,
                                })
                              : FirebaseFirestore.instance
                                  .doc('users/$tenantUid')
                                  .update({'rent': rentController.text});
                          Navigator.pop(context);
                        }
                      },
                    )
                  ],
                ),
                'Edit Tenant');
          },
        )
      ],
    );
  }
}

onDelete(BuildContext context, String tenantUid, String buildingName,
    AsyncSnapshot<DocumentSnapshot> tenantSnap, bool isOffline) {
  return bottomSheet(
    context,
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          child: Text('Delete'),
          color: Colors.red,
          onPressed: () {
            if (!isOffline) {
              updateDoc({'homeId': null, 'rent': null}, 'users/$tenantUid');
              myDoc.update({
                buildingName: FieldValue.arrayRemove([tenantUid]),
                'userCount': FieldValue.arrayRemove([tenantUid]),
              });
              Navigator.pop(context);
            } else {
              myDoc.update({
                'offlineTenants': FieldValue.arrayRemove([tenantUid]),
                buildingName: FieldValue.arrayRemove([tenantUid])
              });
              myDoc.collection('offline').doc(tenantUid).delete();
              Navigator.pop(context);
            }
          },
        ),
        RaisedButton(
          child: Text('Cancel'),
          color: Colors.green,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
    'Do you really want to delete ${tenantSnap.data.data()['name']}',
  );
}
