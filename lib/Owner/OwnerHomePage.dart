import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/MonthlyPaymentsContainer.dart';
import 'package:home_manager/CommonFiles/Settings.dart';
import 'package:home_manager/Owner/TenantList.dart';
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
          !isOffline
              ? addBuilding(context)
              : bottomSheet(
                  context,
                  Column(
                    children: <Widget>[
                      CustomTextField(
                        enabled: true,
                        hintText: 'Tenant Name',
                        onSubmitted: (text) {
                          myDoc().collection('offline').add({
                            'name': text,
                            'accCreated': DateTime.now().year,
                          }).then((value) {
                            myDoc().updateData({
                              'offlineTenants':
                                  FieldValue.arrayUnion([value.documentID]),
                            });
                            myDoc()
                                .collection('offline')
                                .document(value.documentID)
                                .collection('payments')
                                .document('payments')
                                .setData({'exist': true}, merge: true);
                          });

                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  'Add Tenant');
        },
      ),
      body: !isOffline
          ? StreamBuilder(
              stream: myDoc().snapshots(),
              builder: (context, doc) {
                try {
                  if (isOffline) {
                    return Container();
                  } else if (doc.data['expDate'] <=
                          DateTime.now().millisecondsSinceEpoch &&
                      doc.data['userCount'].length != 0) {
                    BotToast.showSimpleNotification(
                        title: 'You subscription has ended...');
                    return Subscription(myDocSnap: doc);
                  } else if (doc.data['requests'].length != 0) {
                    BotToast.showSimpleNotification(title: 'New Request');
                    return Requests();
                  } else if (doc.data['upiId'] == null) {
                    return Center(child: UpdateUpiTile());
                  } else if (doc.data['phoneNum'] != null) {
                    return Owner();
                  } else {
                    return Center(child: UpdatePhoneNumTile());
                  }
                } catch (e) {
                  return Container();
                }
              },
            )
          : OfflineHomePage(),
    );
  }
}

class OfflineHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List offlineTenants;
    return StreamBuilder(
      stream: myDoc().snapshots(),
      builder: (context, snap) {
        try {
          offlineTenants = snap.data['offlineTenants'];
          return ListView.builder(
            shrinkWrap: true,
            itemCount: offlineTenants.length,
            itemBuilder: (context, index) {
              return StreamBuilder(
                stream: myDoc()
                    .collection('offline')
                    .document(offlineTenants[index])
                    .snapshots(),
                builder: (context, snap) {
                  try {
                    return Card(
                      elevation: 10,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        onLongPress: () {
                          onLongPressOnTenantByOwner(
                            context,
                            offlineTenants[index],
                            '',
                            snap,
                            true,
                          );
                        },
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return MonthlyPayments(
                              tenantSnap: snap,
                              isTenant: false,
                              isOffline: true,
                              offlineTenantUid: offlineTenants[index],
                            );
                          }));
                        },
                        title: Text(snap.data['name']),
                        subtitle: Text(snap.data['rent'] ?? 'null'),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            bottomSheet(
                                context,
                                CustomTextField(
                                  enabled: true,
                                  hintText: 'Tenant Rent',
                                  onSubmitted: (rent) {
                                    myDoc()
                                        .collection('offline')
                                        .document(offlineTenants[index])
                                        .updateData({'rent': rent});
                                  },
                                ),
                                'Enter rent');
                          },
                        ),
                      ),
                    );
                  } catch (e) {
                    return Container();
                  }
                },
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

addBuilding(context) {
  bottomSheet(
      context,
      CustomTextField(
        enabled: true,
        hintText: 'ex: Building-1',
        onSubmitted: (buildingName) {
          myDoc().updateData({
            'buildings': FieldValue.arrayUnion([buildingName]),
            buildingName: [],
            'buildingsPhoto': {buildingName: null}
          });
          Navigator.of(context).pop();
        },
      ),
      'Add Building');
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
              print(myDocSnap.data['buildings'][0]);
              return BuildingsCard(
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
