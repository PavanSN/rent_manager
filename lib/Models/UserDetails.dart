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