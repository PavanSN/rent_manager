import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class UserDetails extends StatesRebuilder {
  String name = '';
  String uid = '';
  String photoUrl = '';
  String phoneNum;

  UserDetails() {
    getDetails();
  }

  getDetails() {
    name = FirebaseAuth.instance.currentUser.displayName;
    photoUrl = FirebaseAuth.instance.currentUser.photoURL;
    uid = FirebaseAuth.instance.currentUser.uid;
    phoneNum = FirebaseAuth.instance.currentUser.phoneNumber;
    FirebaseFirestore.instance.doc('users/$uid').update({
      'photoUrl': photoUrl,
      'phoneNum': phoneNum,
    });
  }
}
