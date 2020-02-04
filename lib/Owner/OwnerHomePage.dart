import 'package:flutter/material.dart';
import 'package:getflutter/components/list_tile/gf_list_tile.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/ProfileUi.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:home_manager/Owner/TenantPayments.dart';
import 'package:line_icons/line_icons.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Models/TabPressed.dart';

class Owner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LineIcons.plus),
          onPressed: null,
        ),
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
        ProfileUi(),
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
      stream: streamDoc('users/${Injector
          .get<UserDetails>()
          .uid}'),
      builder: (context, ownerDoc) {
        try {
          return DefaultTabController(
            length: ownerDoc.data['buildings'].length,
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.red,
              indicatorColor: Colors.red,
              unselectedLabelColor: Color(0xff5f6368),
              isScrollable: true,
              tabs: getTabs(ownerDoc),
              onTap: (index) {
                Injector.get<TabPressed>().buildingTapped(index);
                print(Injector
                    .get<TabPressed>()
                    .buildingPressed);
              },
            ),
          );
        } catch (e) {
          print('Error in buildingsTab ${e.toString()}');
          return Text("Loading");
        }
      },
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
      stream: streamDoc('users/${Injector
          .get<UserDetails>()
          .uid}'),
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
                      name: tenantDoc.data['name'],
                    );
                  } catch (e) {
                    return Text('Loading...');
                  }
                },
              );
            },
          );
        } catch (e) {
          print('Error in Buildingsdata ${e.toString()}');
          return Text("Loading...");
        }
      },
    );
  }
}

class TenantsList extends StatelessWidget {
  final AsyncSnapshot tenantDoc;
  final String name;

  TenantsList({this.tenantDoc, this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: GFListTile(
        title: Text(name),
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.call, color: Colors.green),
              onPressed: () {
                launch('tel://${tenantDoc.data['phoneNum'].toString()}');
              },
            ),
            IconButton(
              icon: Icon(
                LineIcons.money,
                color: Colors.teal,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return TenantPayments(tenantDoc: tenantDoc,);
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
