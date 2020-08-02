import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'file:///C:/Users/Pavan/Desktop/rent_manager/lib/Owner/BuildingImageUpdater.dart';

import 'TenantList.dart';

class BuildingsCard extends StatelessWidget {
  final String buildingName;
  final AsyncSnapshot myDocSnap;

  const BuildingsCard({this.buildingName, this.myDocSnap});

  @override
  Widget build(BuildContext context) {
    var buildingPhoto = myDocSnap.data['buildingPhotos'][buildingName] ?? null;
    return Card(
      elevation: 10,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        : 'https://img.icons8.com/bubbles/50/000000/city.png',
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
                              child: Text('Delete Now'),
                              color: Colors.red,
                              onPressed: () async {
                                List buildings;
                                await myDoc().get().then((value) =>
                                    buildings = value.data[buildingName]);
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
                      'Tenants in building : $buildingName',
                    );
                  },
                  color: Colors.green,
                  child: Text('View Tenants'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
