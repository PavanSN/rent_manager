import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

createDoc(data, path) => Firestore.instance.document(path).setData(data);

deleteDoc(path) => Firestore.instance.document(path).delete();

updateDoc(data, path) => Firestore.instance.document(path).updateData(data);

streamColl(path) => Firestore.instance.collection(path).snapshots();

streamDoc(path) => Firestore.instance.document(path).snapshots();

futureDoc(path) => Firestore.instance.document(path).get();

ThemeData theme = ThemeData(
  scaffoldBackgroundColor: Color(0xFFF6F6F6),
  appBarTheme: AppBarTheme(
    brightness: Brightness.light,
    color: Colors.transparent,
    iconTheme: IconThemeData(color: Colors.grey),
    elevation: 0,
  ),
  buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
);

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
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
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
