import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class UserDetails extends StatesRebuilder {
  String name = '';
  String uid = '';
  String photoUrl = '';
  String email = '';
  int buildings = 0;
  double rent = 0;
  String phoneNum;
  int tenantCount = 0;

  UserDetails() {
    getDetails();
  }

  getDetails() {
    FirebaseAuth.instance.currentUser().then((data) {
      name = data.displayName;
      photoUrl = data.photoUrl;
      uid = data.uid;
      email = data.email;
      phoneNum = data.phoneNumber;
      BotToast.showSimpleNotification(title: 'Profile Updated');
      Firestore.instance
          .document('users/$uid')
          .updateData({'photoUrl': photoUrl});
    });
  }
}
