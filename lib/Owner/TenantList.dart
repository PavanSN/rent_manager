import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/MonthlyPaymentsContainer.dart';
import 'package:url_launcher/url_launcher.dart';

class TenantList extends StatelessWidget {
  final String buildingName;
  final rentAmnt;

  TenantList({this.buildingName, this.rentAmnt});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: myDoc().snapshots(),
      builder: (context, snap) {
        try {
          List tenantUids = snap.data[buildingName];
          return ListView.builder(
            shrinkWrap: true,
            itemCount: tenantUids.length,
            itemBuilder: (context, index) {
              return TenantTile(
                tenantUid: tenantUids[index],
                buildingName: buildingName,
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

  const TenantTile({this.tenantUid, this.buildingName, this.rentAmnt});

  @override
  Widget build(BuildContext context) {
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
              trailing: TenantTileTrailingBtn(
                tenantSnap: tenantSnap,
                tenantUid: tenantUid,
                buildingName: buildingName,
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

class TenantTileTrailingBtn extends StatelessWidget {
  final tenantUid;
  final tenantSnap;
  final buildingName;

  TenantTileTrailingBtn({this.tenantSnap, this.tenantUid, this.buildingName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        tenantSnap.data['rent'] == null
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
          onPressed: () =>
              onDelete(context, tenantUid, buildingName, tenantSnap, false),
        ),
        IconButton(
            color: Colors.blue,
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
                      updateDoc({'rent': int.parse(rentAmnt.toString())},
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
    );
  }
}

onDelete(context, tenantUid, buildingName, tenantSnap, isOffline) {
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
              myDoc().updateData({
                buildingName: FieldValue.arrayRemove([tenantUid]),
                'userCount': FieldValue.arrayRemove([tenantUid]),
              });
              Navigator.pop(context);
            } else {
              myDoc().updateData({
                'offlineTenants': FieldValue.arrayRemove([tenantUid])
              });
              myDoc().collection('offline').document(tenantUid).delete();
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
    'Do you really want to delete ${tenantSnap.data['name']}',
  );
}
