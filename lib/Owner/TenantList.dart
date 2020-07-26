import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';

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

  const TenantTile({this.tenantUid});

  @override
  Widget build(BuildContext context) {
    print(tenantUid);
    return StreamBuilder(
      stream: Firestore.instance.document('users/$tenantUid').snapshots(),
      builder: (context, snap) {
        try {
          return Card(
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(snap.data['photoUrl']),
                ),
                onTap: () {
                  //todo tenant payments
                },
                onLongPress: () {
                  //todo delete tenant
                },
                trailing: RaisedButton(
                  color: Colors.deepPurpleAccent,
                  child: Text(
                    'Rent',
                    style: TextStyle(color: Colors.white),
                  ),
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
                  },
                ),
                title: Text(snap.data['name']),
                subtitle: Text('Rent = ${snap.data['rent']}'),
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
