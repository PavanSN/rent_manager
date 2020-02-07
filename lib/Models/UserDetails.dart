import 'package:firebase_auth/firebase_auth.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class UserDetails extends StatesRebuilder {
  String name = '';
  String uid = '';
  String photoUrl = '';
  String email = '';
  int buildings = 0;

  UserDetails() {
    getDetails();
  }

  getDetails() {
    FirebaseAuth.instance.currentUser().then((data) {
      name = data.displayName;
      photoUrl = data.photoUrl;
      uid = data.uid;
      email = data.email;
      rebuildStates();
    });
  }
}

class TenantDB extends StatesRebuilder {
  int accCreated;
  String homeId;
  String name;
  String ownerUpi;
  int phoneNum;
  String rent;
  String uid;

  TenantDB.fromJson(Map json)
      : accCreated = json['accCreated'],
        homeId = json['homeId'],
        name = json['name'],
        ownerUpi = json['ownerUpi'],
        phoneNum = json['phoneNum'],
        rent = json['rent'],
        uid = json['uid'];
}
