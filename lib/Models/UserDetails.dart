import 'package:cloud_firestore/cloud_firestore.dart';
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
    FirebaseAuth.instance.currentUser().then((doc) {
      name = doc.displayName;
      photoUrl = doc.photoUrl;
      uid = doc.uid;
      email = doc.email;
      rebuildStates();
    });
  }
}
