import 'package:flutter/material.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../Models/UserDetails.dart';

class ProfileIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ProfilePhoto(),
          UserName(),
//          HomeID(),
        ],
      ),
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

//class HomeID extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return FutureBuilder(
//      future: futureDoc('users/${Injector.get<UserDetails>().uid}'),
//      builder: (context, userDoc) {
//        if (userDoc.hasData && !userDoc.hasError) {
//          return Text(
//            'Home ID : ${userDoc.data['homeId']}',
//            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//          );
//        } else
//          return Text('Loading');
//      },
//    );
//  }
//}

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
