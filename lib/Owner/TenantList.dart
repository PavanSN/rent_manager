import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/MonthlyPaymentsContainer.dart';
import 'package:url_launcher/url_launcher.dart';

class TenantList extends StatelessWidget {
  final String buildingName;

  TenantList({this.buildingName});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: myDoc().snapshots(),
      builder: (context, snap) {
        try {
          List tenantUids = snap.data[buildingName];
          print(tenantUids);
          return ListView.builder(
            shrinkWrap: true,
            itemCount: tenantUids.length,
            itemBuilder: (context, index) {
              return TenantTile(tenantUid: tenantUids[index]);
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

  const TenantTile({this.tenantUid, this.buildingName});

  @override
  Widget build(BuildContext context) {
    print(tenantUid);
    return StreamBuilder(
      stream: Firestore.instance.document('users/$tenantUid').snapshots(),
      builder: (context, tenantSnap) {
        try {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  tenantSnap.data['photoUrl'],
                  height: 50,
                  width: 50,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return MonthlyPayments(
                        tenantSnap: tenantSnap,
                        isTenant: false,
                      );
                    },
                  ),
                );
              },
              onLongPress: () {
                bottomSheet(
                  context,
                  Row(
                    children: <Widget>[
                      RaisedButton(
                        child: Text('Delete'),
                        color: Colors.red,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      RaisedButton(
                        child: Text('Cancel'),
                        color: Colors.green,
                        onPressed: () {
                          updateDoc(
                              {'uid': null, 'rent': null}, 'users/$tenantUid');
                          myDoc().updateData({
                            buildingName: FieldValue.arrayRemove([tenantUid]),
                            'userCount': FieldValue.arrayRemove([tenantUid]),
                          });
                        },
                      )
                    ],
                  ),
                  'Do you really want to delete ${tenantSnap.data['name']} from $buildingName',
                );
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                      color: Colors.red,
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          child: AlertDialog(
                            title: Text(
                              'Edit Rent',
                              textAlign: TextAlign.center,
                            ),
                            content: CustomTextField(
                              enabled: true,
                              hintText: 'Enter Rent Amount',
                              onSubmitted: (rentAmnt) {
                                updateDoc({'rent': int.parse(rentAmnt)},
                                    'users/$tenantUid');
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        );
                      }),
                  IconButton(
                    color: Colors.green,
                    icon: Icon(Icons.call),
                    onPressed: () {
                      launch('tel:${tenantSnap.data['phoneNum']}');
                    },
                  )
                ],
              ),
              title: Text(tenantSnap.data['name']),
              subtitle: Text('Rent = ${tenantSnap.data['rent']}'),
            ),
          );
        } catch (e) {
          return Container();
        }
      },
    );
  }
}
