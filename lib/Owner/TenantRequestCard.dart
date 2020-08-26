import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:url_launcher/url_launcher.dart';

class Requests extends StatelessWidget {
  final AsyncSnapshot<DocumentSnapshot> myDocSnap;

  Requests({this.myDocSnap});

  @override
  Widget build(BuildContext context) {
    if (myDocSnap.hasData ||
        !myDocSnap.hasError ||
        myDocSnap.data.data()['upiId'] == null) {
      return ListView.builder(
        itemCount: myDocSnap.data.data()['requests'].length,
        itemBuilder: (context, index) {
          return NewTenantRequestCard(
            requesterUid: myDocSnap.data.data()['requests'][index],
          );
        },
      );
    } else
      return Container();
  }
}

class NewTenantRequestCard extends StatelessWidget {
  final String requesterUid;

  NewTenantRequestCard({this.requesterUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamDoc('users/$requesterUid'),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
        try {
          var requesterName = snap.data.data()['name'];
          var requesterPhoto = snap.data.data()['photoUrl'];
          var requesterPhoneNo = snap.data.data()['phoneNum'];
          return Card(
            elevation: 10,
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.network(requesterPhoto),
                      ),
                      title: Text('Tenant Request by $requesterName'),
                      subtitle: Text('Accept only if you know the tenant'),
                      trailing: IconButton(
                          icon: Icon(
                            Icons.call,
                            color: Colors.lightGreen,
                          ),
                          onPressed: () {
                            launch('tel://${requesterPhoneNo.toString()}');
                          }),
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          child: Text('Accept'),
                          color: Colors.green,
                          onPressed: () => onAccept(context, requesterUid),
                        ),
                        RaisedButton(
                          child: Text('Reject'),
                          color: Colors.red,
                          onPressed: () {
                            myDoc.update({
                              'requests': FieldValue.arrayRemove([requesterUid])
                            });
                          },
                        )
                      ],
                    )
                  ],
                ),
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

onAccept(context, requesterUid) {
  myDoc.get().then((value) {
    List buildings = value.data()['buildings'];
    bottomSheet(
        context,
        Column(
          children: <Widget>[
            CustomTextField(
              enabled: true,
              hintText: 'ex: Building-1',
              onSubmitted: (buildingName) {
                myDoc.update({
                  'buildings': FieldValue.arrayUnion([buildingName]),
                  buildingName: FieldValue.arrayUnion([requesterUid]),
                  'requests': FieldValue.arrayRemove([requesterUid]),
                  'userCount': FieldValue.arrayUnion([requesterUid]),
                  'buildingsPhoto': {buildingName: null}
                }).then((_) {
                  updateDoc(
                    {'homeId': FirebaseAuth.instance.currentUser.uid},
                    'users/$requesterUid',
                  );
                  Navigator.pop(context);
                });
              },
            ),
            Visibility(
              visible: buildings.length != 0,
              child: Text('OR'),
            ),
            Visibility(
              visible: buildings.length != 0,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: buildings.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      myDoc.update({
                        buildings[index]: FieldValue.arrayUnion([requesterUid]),
                        'requests': FieldValue.arrayRemove([requesterUid]),
                        'userCount': FieldValue.arrayUnion([requesterUid]),
                      });
                      updateDoc(
                          {'homeId': FirebaseAuth.instance.currentUser.uid},
                          'users/$requesterUid');
                      Navigator.pop(context);
                    },
                    child: Chip(
                      backgroundColor: Colors.deepPurpleAccent,
                      label: Text(
                        buildings[index],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
        'Enter building name');
  });
}
