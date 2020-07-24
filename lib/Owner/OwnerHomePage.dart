import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/PhoneNumberVerification.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:home_manager/Owner/AddTenant.dart';
import 'package:home_manager/Owner/TenantPayments.dart';
import 'package:line_icons/line_icons.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Models/TabPressed.dart';
import 'Subscription.dart';

class CheckSubscription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      observe: () => Injector.get<UserDetails>(),
      builder: (context, _) => StreamBuilder(
        stream: Firestore.instance
            .document('users/${Injector.get<UserDetails>().uid}')
            .snapshots(),
        builder: (context, doc) {
          try {
            if (doc.data['expDate'] <= DateTime.now().millisecondsSinceEpoch &&
                doc.data['userCount'].length != 0) {
              BotToast.showSimpleNotification(
                  title: 'You subscription has ended...');
              return Subscription(
                ownerDocRef: doc,
              );
            } else {
              BotToast.showSimpleNotification(title: 'Welcome Owner');
              String phoneNum = Injector.get<UserDetails>().phoneNum;
              return phoneNum == '' || phoneNum == null
                  ? Center(child: PhoneNumVerificationUI())
                  : Owner();
            }
          } catch (e) {
            return Container(
              color: Colors.white,
            );
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
      stream: streamDoc('users/${Injector
          .get<UserDetails>()
          .uid}'),
      builder: (context, snap) {
        return Scaffold(
          body: ListView(
            children: <Widget>[NewTenantRequest(), TenantsData()],
          ),
        );
      },
    );
  }
}

class NewTenantRequest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

leading(context) {
  return IconButton(
    icon: Icon(LineIcons.plus),
    onPressed: () {
      Firestore.instance
          .document('users/${Injector
          .get<UserDetails>()
          .uid}')
          .get()
          .then((doc) {
        String upiId = doc.data['upiId'];
        return addTenant(context, upiId);
      });
    },
  );
}

class TenantsData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: BuildingsTab(),
        ),
        Expanded(
          flex: 8,
          child: BuildingsData(),
        )
      ],
    );
  }
}

class BuildingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamDoc('users/${Injector.get<UserDetails>().uid}'),
      builder: (context, ownerDoc) {
        try {
          String buildingName = ownerDoc.data['buildings']
              [Injector.get<TabPressed>().buildingPressed];
          return DefaultTabController(
            length: ownerDoc.data['buildings'].length,
            child: GestureDetector(
              onLongPress: () {
                bottomSheet(
                  context,
                  DeleteConfirmation(
                    ownerDoc: ownerDoc,
                  ),
                  'Are you sure you want to delete building $buildingName',
                );
              },
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.red,
                indicatorColor: Colors.red,
                unselectedLabelColor: Color(0xff5f6368),
                isScrollable: true,
                tabs: getTabs(ownerDoc),
                onTap: (index) {
                  Injector.get<TabPressed>().buildingTapped(index);
                },
              ),
            ),
          );
        } catch (e) {
          print('Error in buildingsTab ${e.toString()}');
          return Text("");
        }
      },
    );
  }
}

class DeleteConfirmation extends StatelessWidget {
  final AsyncSnapshot ownerDoc;

  DeleteConfirmation({this.ownerDoc});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          child: Text("Delete building"),
          color: Colors.red,
          onPressed: () async {
            List<String> buildingTenantsUIDs = [];
            String buildingName = ownerDoc.data['buildings']
            [Injector
                .get<TabPressed>()
                .buildingPressed];
            for (DocumentReference doc in ownerDoc.data[buildingName]) {
              buildingTenantsUIDs.add(doc.documentID);
              doc.updateData({
                'homeId': null,
              });
            }
            updateDoc({
              'buildings': FieldValue.arrayRemove([buildingName]),
              buildingName: FieldValue.delete(),
              'userCount': FieldValue.arrayRemove(buildingTenantsUIDs),
            }, 'users/${Injector.get<UserDetails>().uid}');
            Navigator.pop(context);
          },
        ),
        RaisedButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.green,
          child: Text('Go back..'),
        ),
      ],
    );
  }
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

class BuildingsData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamDoc('users/${Injector.get<UserDetails>().uid}'),
      builder: (context, ownerDoc) {
        try {
          String buildingName = ownerDoc.data['buildings']
          [Injector
              .get<TabPressed>()
              .buildingPressed];
          return ListView.builder(
            itemCount: ownerDoc.data[buildingName].length,
            itemBuilder: (context, index) {
              return StreamBuilder(
                stream: ownerDoc.data[buildingName][index].snapshots(),
                builder: (context, tenantDoc) {
                  try {
                    return TenantsList(
                      tenantDoc: tenantDoc,
                      tenantDocRef: ownerDoc.data[buildingName][index],
                      name: tenantDoc.data['name'],
                      tenantBuildingName: buildingName,
                    );
                  } catch (e) {
                    return Text('');
                  }
                },
              );
            },
          );
        } catch (e) {
          print('Error in Buildingsdata ${e.toString()}');
          return Text("");
        }
      },
    );
  }
}

class TenantsList extends StatelessWidget {
  final AsyncSnapshot tenantDoc;
  final String name;
  final DocumentReference tenantDocRef;
  final tenantBuildingName;

  TenantsList(
      {this.tenantDoc, this.name, this.tenantDocRef, this.tenantBuildingName});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onLongPress: () {
          bottomSheet(
              context,
              DeleteTenantPanel(
                tenantBuildingName: tenantBuildingName,
                tenantDocRef: tenantDocRef,
              ),
              "Are you sure you want to remove this tenant..?");
        },
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return TenantPayments(
                  tenantDoc: tenantDoc,
                  isTenant: false,
                  tenantDocRef: tenantDocRef,
                );
              },
            ),
          );
        },
        title: Text(name, style: Theme.of(context).textTheme.subtitle1),
        leading: Icon(Icons.person, color: Colors.pink),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.call, color: Colors.green),
              onPressed: () {
                launch('tel://${tenantDoc.data['phoneNum'].toString()}');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DeleteTenantPanel extends StatelessWidget {
  DeleteTenantPanel({this.tenantBuildingName, this.tenantDocRef});

  final String tenantBuildingName;
  final DocumentReference tenantDocRef;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          color: Colors.red,
          child: Text("Delete"),
          onPressed: () {
            var tenantSide = {
              'homeId': null,
              'rent': null,
            };
            var ownerSide = {
              tenantBuildingName: FieldValue.arrayRemove([tenantDocRef]),
              'userCount': FieldValue.arrayRemove([tenantDocRef.documentID]),
            };
            tenantDocRef.updateData(tenantSide);
            myDoc().updateData(ownerSide);
          },
        ),
        RaisedButton(
          color: Colors.green,
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
