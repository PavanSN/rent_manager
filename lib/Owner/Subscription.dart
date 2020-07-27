import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/PaymentMethodsBtmSheet.dart';

class Subscription extends StatelessWidget {
  final AsyncSnapshot ownerDocRef;

  const Subscription({this.ownerDocRef});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Subscription Expired',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
      ),
      body: SubscriptionOffers(
        ownerDocRef: ownerDocRef,
      ),
    );
  }
}

class SubscriptionOffers extends StatelessWidget {
  final AsyncSnapshot ownerDocRef;

  const SubscriptionOffers({Key key, this.ownerDocRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int amount = ownerDocRef.data['userCount'].length * 10;
    return ListView(
      children: <Widget>[
        SubscriptionCard(
          amount: amount,
          color: Colors.pink,
          title: Text(
            'Pay ₹10/Tenant per month',
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
          onPressed: () {
            var date = DateTime.now();
            bottomSheet(
                context,
                PaymentMethods(
                  monthYear: '${date.month}${date.year}',
                  amount: amount.toDouble(),
                  expDate: DateTime.now()
                      .add(Duration(days: 30))
                      .millisecondsSinceEpoch,
                ),
                'Pay Using');
          },
        ),
      ],
    );
  }
}

class SubscriptionCard extends StatelessWidget {
  final Color color;
  final Widget title;
  final Function onPressed;
  final int amount;

  SubscriptionCard({this.color, this.title, this.onPressed, this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      height: MediaQuery.of(context).size.height * 0.4,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            title,
            RaisedButton(
              child: Text(
                'Pay ₹$amount',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
              ),
              onPressed: onPressed,
              color: Colors.white,
            ),
          ],
        ),
        color: color,
      ),
    );
  }
}
