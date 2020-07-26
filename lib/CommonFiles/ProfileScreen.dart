import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'CommonWidgetsAndData.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Text(
              Injector.get<UserDetails>().tenantCount.toString(),
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
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
    Injector.get<UserDetails>().getDetails();
    return Text('Phone No : ${Injector.get<UserDetails>().phoneNum}');
  }
}

class ProfilePhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      observe: () => Injector.get<UserDetails>(),
      builder: (context, _) {
        return Material(
          elevation: 15,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          child: CircleAvatar(
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
                      'users/${Injector.get<UserDetails>().uid}');
                  BotToast.showSimpleNotification(
                      title: 'UPI Updated successfully');
                  Navigator.pop(context);
                } else
                  BotToast.showSimpleNotification(title: 'Invalid UPI ID');
              },
            ),
            'Update UPI');
      },
      child: StreamBuilder(
        stream: streamDoc('users/${Injector.get<UserDetails>().uid}'),
        builder: (context, userDoc) {
          try {
            return Text(
              'UPI ID : ${userDoc.data['upiId']}',
            );
          } catch (e) {
            return Text('Loading');
          }
        },
      ),
    );
  }
}

class UserName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      observe: () => Injector.get<UserDetails>(),
      builder: (context, _) {
        return Text(
          'Hello, ${Injector.get<UserDetails>().name}',
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(fontWeight: FontWeight.w300),
        );
      },
    );
  }
}
