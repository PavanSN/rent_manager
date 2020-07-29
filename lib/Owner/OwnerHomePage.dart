import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/Settings.dart';
import 'package:share/share.dart';

import 'BuildingCard.dart';
import 'Subscription.dart';
import 'TenantRequestCard.dart';

class CheckSubscription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Owner',
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(
                  'https://play.google.com/store/apps/details?id=com.pavansn.rent_manager');
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: myDoc().snapshots(),
        builder: (context, doc) {
          try {
            if (doc.data['expDate'] <= DateTime.now().millisecondsSinceEpoch &&
                doc.data['userCount'].length != 0) {
              BotToast.showSimpleNotification(
                  title: 'You subscription has ended...');
              return Subscription(myDocSnap: doc);
            } else if (doc.data['requests'].length != 0) {
              BotToast.showSimpleNotification(title: 'New Request');
              return Requests();
            } else if (doc.data['upiId'] == null) {
              return Center(child: UpdateUpiTile());
            } else if (doc.data['phoneNum'] != null) {
              return Owner();
            } else {
              return Center(child: UpdatePhoneNumTile());
            }
          } catch (e) {
            return Container();
          }
        },
      ),
    );
  }
}

class Owner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: myDoc().snapshots(),
      builder: (context, myDocSnap) {
        try {
          myDocSnap.data['buildings'].length == 0
              ? BotToast.showSimpleNotification(
                  title: 'You will be notified when tenant adds you')
              : BotToast.showSimpleNotification(title: 'Welcome Owner');
          return ListView.builder(
            itemCount: myDocSnap.data['buildings'].length,
            itemBuilder: (context, index) {
              return BuildingsCard(
                buildingName: myDocSnap.data['buildings'][index],
                myDocSnap: myDocSnap,
              );
            },
          );
        } catch (e) {
          return Container();
        }
      },
    );
  }
}
