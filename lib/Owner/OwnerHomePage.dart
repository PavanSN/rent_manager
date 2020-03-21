import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getflutter/components/button/gf_button.dart';
import 'package:getflutter/components/list_tile/gf_list_tile.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/ProfileUi.dart';
import 'package:home_manager/CommonFiles/Settings.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:home_manager/Owner/AddTenant.dart';
import 'package:home_manager/Owner/TenantPayments.dart';
import 'package:line_icons/line_icons.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Models/TabPressed.dart';

class CheckSubscription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamDoc('users/${Injector.get<UserDetails>().uid}'),
      builder: (context, ownerDoc) {
        return Owner();
      },
    );
  }
}

class Owner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LineIcons.plus),
          onPressed: () {
            Firestore.instance
                .document('users/${Injector.get<UserDetails>().uid}')
                .get()
                .then((doc) {
              String upiId = doc.data['upiId'];
              return addTenant(context, upiId);
            });
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(LineIcons.wrench),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Settings();
                },
              ),
            ),
          ),
        ],
      ),
      body: OwnerBody(),
    );
  }
}

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
      stream: streamDoc('users/${Injector.get<UserDetails>().uid}'),
      builder: (context, ownerDoc) {
        try {
          return DefaultTabController(
            length: ownerDoc.data['buildings'].length,
            child: GestureDetector(
              onLongPress: () {
                bottomSheet(
                  context,
                  DeleteConfirmation(
                    ownerDoc: ownerDoc,
                  ),
                  'Entire data of the building will be deleted and cannot be recovered',
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
  final ownerDoc;

  DeleteConfirmation({this.ownerDoc});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        GFButton(
          text: 'Delete building',
          color: Colors.red,
          onPressed: () {
            Navigator.pop(context);
            updateDoc({
              'buildings': FieldValue.arrayRemove(
                [
                  ownerDoc.data['buildings']
                      [Injector.get<TabPressed>().buildingPressed]
                ],
              ),
            }, 'users/${Injector.get<UserDetails>().uid}');
          },
        ),
        GFButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.green,
          text: 'Go back..',
        )
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
              [Injector.get<TabPressed>().buildingPressed];
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

  String tenantBuildingName;
  DocumentReference tenantDocRef;

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
              tenantBuildingName.toString():
                  FieldValue.arrayRemove([tenantDocRef]),
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
