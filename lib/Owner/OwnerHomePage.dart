import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getflutter/components/button/gf_button.dart';
import 'package:getflutter/components/list_tile/gf_list_tile.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/LoadingScreen.dart';
import 'package:home_manager/CommonFiles/ProfileUi.dart';
import 'package:home_manager/CommonFiles/Settings.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:home_manager/Owner/AddTenant.dart';
import 'package:home_manager/Owner/TenantPayments.dart';
import 'package:line_icons/line_icons.dart';
import 'package:share/share.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Models/TabPressed.dart';

class CheckIfOwner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .document('users/${Injector
          .get<UserDetails>(context: context)
          .uid}')
          .snapshots(),
      builder: (context, doc) {
        try {
          bool isTenant = doc.data['isTenant'];
          if (isTenant == null) {
            return updateDoc({'isTenant': false},
                'users/${Injector
                    .get<UserDetails>(context: context)
                    .uid}');
          } else {
            if (isTenant) {
              return ShowNotOwnerScreen();
            } else {
              return Owner();
            }
          }
        } catch (e) {
          return LoadingScreen();
        }
      },
    );
  }
}

class ShowNotOwnerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Seems like you\'re the Tenant, Try to install Rent Manager (Tenant)',
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 25,
            ),
            RaisedButton(
              color: Colors.green,
              child: Text("Install Now"),
              onPressed: () {
                launch(
                    'https://play.google.com/store/apps/details?id=com.pavansn.rent_manager_tenant');
              },
            )
          ],
        ),
      ),
    );
  }
}

class Owner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Owner',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: leading(context),
        actions: actions(context),
      ),
      body: OwnerBody(),
    );
  }
}

List<Widget> actions(context) =>
    [
      IconButton(
        icon: Icon(Icons.share),
        onPressed: () =>
            Share.share(
              'Hey guys, Now you can pay and manage rent using this free app https://play.google.com/store/apps/details?id=com.pavansn.rent_manager_tenant',
            ),
      ),
      IconButton(
        icon: Icon(
          Icons.info,
          color: Colors.grey,
        ),
        onPressed: () {
          bottomSheet(
            context,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Sometimes transaction confirmation fails, If tenant show's proof of transaction details then edit the rent (paid or unpaid) accordingly. Please Share this app with your tenants and real estate owners to manage business efficiently",
                textAlign: TextAlign.center,
              ),
            ),
            "Already Paid..?",
          );
        },
      ),
      IconButton(
        icon: Icon(LineIcons.wrench),
        onPressed: () =>
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Settings();
                },
              ),
            ),
      ),
    ];

leading(context) =>
    IconButton(
      icon: Icon(LineIcons.plus),
      onPressed: () {
        Firestore.instance
            .document(
            'users/${Injector
                .get<UserDetails>(context: context)
                .uid}')
            .get()
            .then((doc) {
          String upiId = doc.data['upiId'];
          return addTenant(context, upiId);
        });
      },
    );

class OwnerBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ProfileUi(
          isOwner: true,
        ),
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
      stream:
      streamDoc('users/${Injector
          .get<UserDetails>(context: context)
          .uid}'),
      builder: (context, ownerDoc) {
        try {
          String buildingName = ownerDoc.data['buildings']
          [Injector
              .get<TabPressed>(context: context)
              .buildingPressed];
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
                  Injector.get<TabPressed>(context: context)
                      .buildingTapped(index);
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
  AsyncSnapshot ownerDoc;

  DeleteConfirmation({this.ownerDoc});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        GFButton(
          text: 'Delete building',
          color: Colors.red,
          onPressed: () async {
            List<String> buildingTenantsUIDs = [];
            String buildingName = ownerDoc.data['buildings']
            [Injector
                .get<TabPressed>(context: context)
                .buildingPressed];
            for (DocumentReference doc in ownerDoc.data[buildingName]) {
              buildingTenantsUIDs.add(doc.documentID);
            }
            updateDoc({
              'buildings': FieldValue.arrayRemove([buildingName]),
              buildingName: FieldValue.delete(),
              'userCount': FieldValue.arrayRemove(buildingTenantsUIDs),
            }, 'users/${Injector
                .get<UserDetails>(context: context)
                .uid}');
            Navigator.pop(context);
          },
        ),
        GFButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.green,
          text: 'Go back..',
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
      stream:
      streamDoc('users/${Injector
          .get<UserDetails>(context: context)
          .uid}'),
      builder: (context, ownerDoc) {
        try {
          String buildingName = ownerDoc.data['buildings']
          [Injector
              .get<TabPressed>(context: context)
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
    return GestureDetector(
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
      child: Card(
        child: GFListTile(
          title: Text(name),
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  bottomSheet(
                      context,
                      DeleteTenantPanel(
                        tenantBuildingName: tenantBuildingName,
                        tenantDocRef: tenantDocRef,
                      ),
                      "Are you sure you want to remove this tenant..?");
                },
              ),
              IconButton(
                icon: Icon(Icons.call, color: Colors.green),
                onPressed: () {
                  launch('tel://${tenantDoc.data['phoneNum'].toString()}');
                },
              ),
            ],
          ),
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
        GFButton(
          color: Colors.red,
          text: "Delete",
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
        GFButton(
          color: Colors.green,
          text: "Cancel",
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
