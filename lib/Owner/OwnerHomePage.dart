import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/PhoneNumberVerification.dart';
import 'package:home_manager/CommonFiles/ProfileImageUpdater.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:home_manager/Owner/TenantList.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Subscription.dart';

class CheckSubscription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: myDoc().snapshots(),
        builder: (context, doc) {
          try {
            if (doc.data['expDate'] <= DateTime.now().millisecondsSinceEpoch &&
                doc.data['userCount'].length != 0) {
              BotToast.showSimpleNotification(
                  title: 'You subscription has ended...');
              return Subscription(
                ownerDocRef: doc,
              );
            } else if (doc.data['requests'].length != 0) {
              BotToast.showSimpleNotification(title: 'New Request');
              return Requests();
            } else {
              String phoneNum = doc.data['phoneNum'];
              return phoneNum != null
                  ? Owner()
                  : Center(child: PhoneNumVerificationUI());
            }
          } catch (e) {
            return Container();
          }
        },
      ),
    );
  }
}

class Owner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: myDoc().snapshots(),
      builder: (context, myDocSnap) {
        try {
          myDocSnap.data['buildings'].length == 0
              ? BotToast.showSimpleNotification(
                  title: 'You will be notified when tenant adds you')
              : BotToast.showSimpleNotification(title: 'Welcome Owner');
          return ListView.builder(
            itemCount: myDocSnap.data['buildings'].length,
            itemBuilder: (context, index) {
              return BuildingsTile(
                buildingName: myDocSnap.data['buildings'][index],
                myDocSnap: myDocSnap,
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

class BuildingsTile extends StatelessWidget {
  final String buildingName;
  final AsyncSnapshot myDocSnap;

  const BuildingsTile({this.buildingName, this.myDocSnap});

  @override
  Widget build(BuildContext context) {
    var buildingPhoto = myDocSnap.data['buildingPhotos'][buildingName] ?? null;
    return Card(
      elevation: 10,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        height: MediaQuery.of(context).size.height * 0.2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ListTile(
              onTap: () => null,
              title: Text(buildingName),
              subtitle:
                  Text('Tenants : ${myDocSnap.data[buildingName].length}'),
              leading: GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return ImageCapture(buildingName: buildingName);
                  }));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    (buildingPhoto != null)
                        ? buildingPhoto
                        : 'https://img.icons8.com/color/96/000000/city-buildings.png',
                    fit: BoxFit.cover,
                    height: 50,
                    width: 50,
                  ),
                ),
              ),
            ),
            Container(height: 1, color: Colors.grey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
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
                              child: Text(
                                'Delete Now',
                              ),
                              color: Colors.red,
                              onPressed: () async {
                                List buildings;
                                await myDoc().get().then((value) =>
                                    buildings = value.data[buildingName]);
                                print(buildings);
                                buildings.forEach((tenantUid) {
                                  updateDoc(
                                      {'homeId': null}, 'users/$tenantUid');
                                });
                                myDoc().updateData({
                                  'buildingPhotos':
                                      FieldValue.arrayRemove([buildingName]),
                                  'buildings':
                                      FieldValue.arrayRemove([buildingName]),
                                  'userCount':
                                      FieldValue.arrayRemove(buildings),
                                  buildingName: FieldValue.delete(),
                                }).then((value) {
                                  FirebaseStorage.instance
                                      .ref()
                                      .child(
                                          'profiles/${Injector.get<UserDetails>().uid}$buildingName.png')
                                      .delete();
                                });
                              },
                            ),
                          ],
                        ),
                        'Warning');
                  },
                  color: Colors.red,
                  child: Text('Delete Building'),
                ),
                RaisedButton(
                  onPressed: () {
                    bottomSheet(
                        context,
                        TenantList(
                          buildingName: buildingName,
                        ),
                        'Tenants in building : $buildingName');
                  },
                  color: Colors.green,
                  child: Text('View Tenants'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Requests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: myDoc().snapshots(),
      builder: (context, snap) {
        if (snap.hasData && !snap.hasError) {
          print(snap.data['requests'].length);
          return ListView.builder(
            itemCount: snap.data['requests'].length,
            itemBuilder: (context, index) {
              return NewTenantRequestCard(
                  requesterUid: snap.data['requests'][index]);
            },
          );
        } else
          return Container();
      },
    );
  }
}

class NewTenantRequestCard extends StatelessWidget {
  final String requesterUid;

  const NewTenantRequestCard({this.requesterUid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureDoc('users/$requesterUid'),
      builder: (context, snap) {
        try {
          var requesterName = snap.data['name'];
          var requesterPhoto = snap.data['photoUrl'];
          var requesterPhoneNo = snap.data['phoneNum'];
          return Card(
            elevation: 10,
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
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
                            myDoc().updateData({
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
  myDoc().get().then((value) {
    List buildings = value.data['buildings'];
    print(buildings);
    bottomSheet(
        context,
        Column(
          children: <Widget>[
            CustomTextField(
              enabled: true,
              hintText: 'ex: Building-1',
              onSubmitted: (buildingName) {
                myDoc().updateData({
                  'buildings': FieldValue.arrayUnion([buildingName]),
                  buildingName: FieldValue.arrayUnion([requesterUid]),
                  'requests': FieldValue.arrayRemove([requesterUid]),
                  'userCount': FieldValue.arrayUnion([requesterUid]),
                  'buildingPhotos': {buildingName: null}
                }).then((_) {
                  updateDoc({'homeId': requesterUid}, 'users/$requesterUid');
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
                      myDoc().updateData({
                        buildings[index]: FieldValue.arrayUnion([requesterUid]),
                        'requests': FieldValue.arrayRemove([requesterUid]),
                        'userCount': FieldValue.arrayUnion([requesterUid]),
                      });
                      updateDoc(
                          {'homeId': requesterUid}, 'users/$requesterUid');
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

getTabs(AsyncSnapshot ownerDoc) {
  int buildingsLength = ownerDoc.data['buildings'].length;
  List<Tab> tabs = [];
  for (int i = 0; i < buildingsLength; i++) {
    tabs.add(Tab(
      text: ownerDoc.data['buildings'][i],
    ));
  }
  return tabs;
}
