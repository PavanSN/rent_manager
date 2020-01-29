import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'UserDetails.dart';

class UserDB extends StatesRebuilder {
  int accCreated = 0;

  UserDB() {
    getAccCreated();
  }

  getAccCreated() {
    Firestore.instance
        .document('users/${Injector.get<UserDetails>().uid}')
        .get()
        .then((doc) {
      accCreated = doc.data['accCreated'];
      rebuildStates();
      return accCreated;
    });
  }
}
