import 'package:firebase_auth/firebase_auth.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class UserDetails extends StatesRebuilder {
  String name = '';
  String uid = '';
  String photoUrl = '';
  String email = '';

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
