import 'package:flutter/material.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../Models/UserDetails.dart';
import 'CommonWidgetsAndData.dart';

class ProfileUi extends StatelessWidget {
  final bool isOwner;

  ProfileUi({this.isOwner});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ProfilePhoto(),
            UserName(),
            Visibility(
              visible: isOwner,
              child: UpiID(),
            ),
            Visibility(
              visible: isOwner,
              child: SubscriptionExpiry(),
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionExpiry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureDoc('users/${Injector
          .get<UserDetails>()
          .uid}'),
      builder: (context, userDoc) {
        try {
          var date = DateTime.fromMicrosecondsSinceEpoch(
            userDoc.data['expDate'] * 1000,
          );
          return Text(
            'Subscription ends on ${DateTime.utc(
                date.year, date.month, date.day).toLocal()}',
          );
        } catch (e) {
          return Text('Loading...');
        }
      },
    );
  }
}

class ProfilePhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      models: [Injector.get<UserDetails>()],
      builder: (context, _) {
        return Material(
          elevation: 15,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          child: GFAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage(Injector.get<UserDetails>().photoUrl),
          ),
        );
      },
    );
  }
}

class UpiID extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureDoc('users/${Injector
          .get<UserDetails>()
          .uid}'),
      builder: (context, userDoc) {
        try {
          return Text(
            'UPI ID : ${userDoc.data['upiId']}',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
          );
        } catch (e) {
          return Text('Loading');
        }
      },
    );
  }
}

class UserName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      models: [Injector.get<UserDetails>()],
      builder: (context, _) {
        return Text(
          'Hello, ${Injector.get<UserDetails>().name}',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w300),
        );
      },
    );
  }
}
