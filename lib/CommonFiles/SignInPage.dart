import 'package:flutter/material.dart';

import '../Models/SignIn.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
      ),
      backgroundColor: Colors.white,
      body: BodyForeGround(),
    );
  }
}

class BodyForeGround extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Image.asset('assets/SignInImage.png'),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            width: MediaQuery.of(context).size.width * 0.9,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 15,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Image.asset('assets/logo.png'),
                  Text(
                    'Rent Manager',
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
                  ),
                  SignInBtn(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SignInBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 10,
      onPressed: () => SignIn().signIn(),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              'assets/google_icon.png',
              scale: 1.2,
            ),
            SizedBox(
              width: 10,
            ),
            Text('Sign In'),
          ],
        ),
      ),
    );
  }
}
