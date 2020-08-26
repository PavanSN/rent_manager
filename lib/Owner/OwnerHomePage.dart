import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/Settings.dart';
import 'package:share/share.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'BuildingCard.dart';
import 'Subscription.dart';
import 'TenantRequestCard.dart';

class CheckSubscription extends StatefulWidget {
  @override
  _CheckSubscriptionState createState() => _CheckSubscriptionState();
}

class _CheckSubscriptionState extends State<CheckSubscription> {
  bool isOffline = false;
  int labelIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: ToggleSwitch(
          inactiveBgColor: Colors.white24,
          labels: ['Online', 'Offline'],
          changeOnTap: true,
          initialLabelIndex: labelIndex,
          onToggle: (index) {
            labelIndex = index;
            index == 0 ? isOffline = false : isOffline = true;
            setState(() {});
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(
                  'https://play.google.com/store/apps/details?id=com.pavansn.rent_manager');
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
        onPressed: () {
          !isOffline ? addBuilding(context, false) : addBuilding(context, true);
        },
      ),
      body: StreamBuilder(
        stream: myDoc.snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> doc) {
          try {
            if (doc.data.data()['expDate'] <=
                    DateTime.now().millisecondsSinceEpoch &&
                (doc.data.data()['userCount'].length != 0 ||
                    doc.data.data()['offlineTenants'].length != 0)) {
              BotToast.showSimpleNotification(
                  title: 'You subscription has ended...');
              return Subscription(myDocSnap: doc);
            } else if (doc.data.data()['requests'].length != 0) {
              BotToast.showSimpleNotification(title: 'New Request');
              return Requests(myDocSnap: doc);
            } else if (doc.data.data()['upiId'] == null) {
              return Center(child: UpdateUpiTile());
            } else if (doc.data.data()['phoneNum'] != null) {
              return Owner(isOffline: isOffline);
            } else {
              return Center(child: UpdatePhoneNumTile());
            }
          } catch (e) {
            return Container();
          }
        },
      ),
    );
  }
}

addBuilding(context, isOffline) {
  bool isDuplicateBuilding = false;
  bottomSheet(
      context,
      CustomTextField(
        enabled: true,
        hintText: 'ex: Building-1',
        onSubmitted: (buildingName) {
          //todo remove update offlineBuidings after blaze plan

          myDoc.get().then((doc) {
            List onlineBuildings = doc.data()['buildings'];
            List offlineBuildings = doc.data()['offlineBuildings'];
            onlineBuildings.forEach((name) {
              if (buildingName == name) {
                BotToast.showSimpleNotification(
                    title: 'Building already exists');
                isDuplicateBuilding = true;
              }
            });

            if (offlineBuildings == null) {
              updateDoc({'offlineBuildings': []},
                  'users/${FirebaseAuth.instance.currentUser.uid}');
            } else {
              offlineBuildings.forEach((name) {
                if (buildingName == name) {
                  BotToast.showSimpleNotification(
                      title: 'Building already exists');
                  isDuplicateBuilding = true;
                }
              });
            }
            if (!isOffline && !isDuplicateBuilding) {
              myDoc.update({
                'buildings': FieldValue.arrayUnion([buildingName]),
                buildingName: [],
                'buildingsPhoto': {buildingName: null}
              });
            } else if (isOffline && !isDuplicateBuilding) {
              myDoc.update({
                'offlineBuildings': FieldValue.arrayUnion([buildingName]),
                buildingName: [],
                'buildingsPhoto': {buildingName: null}
              });
            }
          });
        },
      ),
      'Add Building');
}

class Owner extends StatelessWidget {
  final isOffline;

  Owner({this.isOffline});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: myDoc.snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> myDocSnap) {
        try {
          if (!isOffline) {
            return myDocSnap.data.data()['buildings'].length == 0
                ? BotToast.showSimpleNotification(
                title: 'You will be notified when tenant adds you')
                : ListView.builder(
              itemCount: myDocSnap.data.data()['buildings'].length,
              itemBuilder: (context, index) {
                return BuildingsCard(
                  buildingName: myDocSnap.data.data()['buildings'][index],
                  myDocSnap: myDocSnap,
                  isOffline: isOffline,
                );
              },
            );
          } else {
            return myDocSnap.data.data()['offlineBuildings'].length == 0
                ? BotToast.showSimpleNotification(
                title: 'No offline tenants, Add one...')
                : ListView.builder(
              itemCount: myDocSnap.data.data()['offlineBuildings'].length,
              itemBuilder: (context, index) {
                print(myDocSnap.data.data()['offlineBuildings'][index]);
                return BuildingsCard(
                  buildingName: myDocSnap.data.data()['offlineBuildings']
                  [index],
                  myDocSnap: myDocSnap,
                  isOffline: isOffline,
                );
              },
            );
          }
        } catch (e) {
          return Container();
        }
      },
    );
  }
}
