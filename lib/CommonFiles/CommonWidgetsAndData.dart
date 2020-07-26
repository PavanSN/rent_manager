import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

createDoc(data, path) => Firestore.instance.document(path).setData(data);

deleteDoc(path) => Firestore.instance.document(path).delete();

updateDoc(data, path) => Firestore.instance.document(path).updateData(data);

Stream<DocumentSnapshot> streamDoc(path) =>
    Firestore.instance.document(path).snapshots();

Future<DocumentSnapshot> futureDoc(path) =>
    Firestore.instance.document(path).get();

DocumentReference myDoc() =>
    Firestore.instance.document('users/${Injector.get<UserDetails>().uid}');

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final enabled;
  final hintText;
  final onSubmitted;

  CustomTextField(
      {this.controller,
      this.enabled,
      this.hintText,
      this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: TextFormField(
        onFieldSubmitted: onSubmitted,
        initialValue: '',
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class TextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

ThemeData theme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      brightness: Brightness.light,
      color: Colors.transparent,
      iconTheme: IconThemeData(color: Colors.grey),
      elevation: 0,
    ),
    buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
    primaryColor: Colors.red,
    accentColor: Colors.redAccent,
    cursorColor: Colors.red);

String nameOfMonth(month) {
  switch (month) {
    case 1:
      return 'Jan';
      break;
    case 2:
      return 'Feb';
      break;
    case 3:
      return 'Mar';
      break;
    case 4:
      return 'Apr';
      break;
    case 5:
      return 'May';
      break;
    case 6:
      return 'Jun';
      break;
    case 7:
      return 'Jul';
      break;
    case 8:
      return 'Aug';
      break;
    case 9:
      return 'Sep';
      break;
    case 10:
      return 'Oct';
      break;
    case 11:
      return 'Nov';
      break;
    case 12:
      return 'Dec';
      break;
  }
  return 'null';
}

bottomSheet(context, body, headingText) => showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery
              .of(context)
              .viewInsets,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              Text(
                headingText,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 22),
              ),
              SizedBox(
                height: 15,
              ),
              body,
            ],
          ),
        );
      },
    );
