import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'CommonWidgetsAndData.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          ProfileUi(),
          TenantCountUi(),
        ],
      ),
    );
  }
}

class TenantCountUi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        height: MediaQuery.of(context).size.height * 0.1,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              'Tenant\'s Count',
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16),
            ),
            Container(
              width: 0.5,
              color: Colors.black,
            ),
            FutureBuilder(
              future: myDoc.get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
                try {
                  return Text(
                    (snap.data.data()['userCount'].length +
                            snap.data.data()['offlineTenants'].length)
                        .toString(),
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
                  );
                } catch (e) {
                  return Text('0');
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

class ProfileUi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 10,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.30,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ProfilePhoto(),
              UserName(),
              UpiID(),
              PhoneNum(),
            ],
          ),
        ),
      ),
    );
  }
}

class PhoneNum extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Phone No : ${FirebaseAuth.instance.currentUser.phoneNumber}');
  }
}

class ProfilePhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Image.network(
        FirebaseAuth.instance.currentUser.photoURL,
        height: 60,
        width: 60,
      ),
    );
  }
}

class UpiID extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        bottomSheet(
            context,
            CustomTextField(
              enabled: true,
              hintText: "UPI ID",
              onSubmitted: (upiId) {
                if (upiId.toString().contains('@')) {
                  updateDoc({'upiId': upiId},
                      'users/${FirebaseAuth.instance.currentUser.uid}');
                  Fluttertoast.showToast(msg: 'UPI Updated successfully');
                  Navigator.pop(context);
                } else
                  Fluttertoast.showToast(msg: 'Invalid UPI ID');
              },
            ),
            'Update UPI');
      },
      child: StreamBuilder(
        stream: streamDoc('users/${FirebaseAuth.instance.currentUser.uid}'),
        builder: (context, AsyncSnapshot<DocumentSnapshot> userDoc) {
          try {
            return Text(
              'UPI ID : ${userDoc.data.data()['upiId']}',
            );
          } catch (e) {
            return Text('UPI ID :');
          }
        },
      ),
    );
  }
}

class UserName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Hello, ${FirebaseAuth.instance.currentUser.displayName}',
      style: Theme
          .of(context)
          .textTheme
          .headline6
          .copyWith(fontWeight: FontWeight.w300),
    );
  }
}
