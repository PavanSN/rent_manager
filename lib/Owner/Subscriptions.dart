import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/Models/PayUsingUpi.dart';
import 'package:line_icons/line_icons.dart';
import 'package:upi_india/upi_india.dart';

class Subscriptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Subscribe',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SubscriptionsBody(),
      ),
    );
  }
}

class SubscriptionsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        BeautifulCard(
          color: Colors.deepPurple,
          pay: "Pay Monthly",
          payAmount: "₹50 / 30 Days",
          onPressed: () {
            var date = DateTime.now();
            var expDate = DateTime(date.year, date.month, date.day + 30)
                .millisecondsSinceEpoch;

            bottomSheet(
                context,
                PaymentMethods(
                  amount: 50,
                  expDate: expDate,
                ),
                'Pay Using');
          },
        ),
        SizedBox(
          height: 15,
        ),
        BeautifulCard(
          color: Colors.orange,
          pay: "Pay Yearly",
          payAmount: "₹500 / 365 Days",
          onPressed: () {
            var date = DateTime.now();
            var expDate = DateTime(date.year, date.month, date.day + 365)
                .millisecondsSinceEpoch;

            bottomSheet(
                context,
                PaymentMethods(
                  amount: 500,
                  expDate: expDate,
                ),
                'Pay Using');
          },
        ),
      ],
    );
  }
}

class PaymentMethods extends StatelessWidget {
  final double amount;
  final expDate;

  PaymentMethods({this.amount, this.expDate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        PaymentMethodTile(
          amount: amount,
          expDate: expDate,
          title: 'GooglePay',
          leadingIcon: Icon(
            LineIcons.google_wallet,
            color: Colors.blue,
          ),
          app: UpiIndiaApps.GooglePay,
        ),
        PaymentMethodTile(
          amount: amount,
          expDate: expDate,
          title: 'PhonePe',
          leadingIcon: Icon(
            LineIcons.paypal,
            color: Colors.deepPurpleAccent,
          ),
          app: UpiIndiaApps.PhonePe,
        ),
        PaymentMethodTile(
          amount: amount,
          expDate: expDate,
          title: 'MiPay',
          leadingIcon: Icon(
            LineIcons.money,
            color: Colors.orange,
          ),
          app: UpiIndiaApps.MiPay,
        ),
        PaymentMethodTile(
          amount: amount,
          expDate: expDate,
          title: 'PayTM',
          leadingIcon: Icon(
            LineIcons.bank,
            color: Colors.lightBlueAccent,
          ),
          app: UpiIndiaApps.PayTM,
        ),
        PaymentMethodTile(
          amount: amount,
          expDate: expDate,
          title: 'AmazonPay',
          leadingIcon: Icon(
            LineIcons.amazon,
            color: Colors.black,
          ),
          app: UpiIndiaApps.AmazonPay,
        ),
      ],
    );
  }
}

class PaymentMethodTile extends StatelessWidget {
  final double amount;
  final String title;
  final Icon leadingIcon;
  final expDate;
  final app;

  PaymentMethodTile(
      {this.title, this.leadingIcon, this.amount, this.expDate, this.app});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        try {
          PayUsingUpi(
            app: app,
            amount: amount,
            expDate: expDate,
            isTenant: false,
            receiverUpi: '7975892709@okbizaxis',
          );
        } catch (e) {
          Fluttertoast.showToast(msg: e);
        }
      },
      child: Card(
        child: ListTile(
          title: Text(title),
          leading: leadingIcon,
        ),
      ),
    );
  }
}

class BeautifulCard extends StatelessWidget {
  final Color color;
  final String pay;
  final String payAmount;
  final Function onPressed;

  BeautifulCard({this.color, this.pay, this.payAmount, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              pay,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 25),
            ),
            Text(
              payAmount,
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w300),
            ),
            RaisedButton(
              color: Colors.white,
              padding: EdgeInsets.all(15),
              child: Text('    Pay Now    '),
              onPressed: onPressed,
            )
          ],
        ),
      ),
    );
  }
}
