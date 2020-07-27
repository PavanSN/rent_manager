import 'package:flutter/material.dart';
import 'package:home_manager/Models/PayUsingUpi.dart';
import 'package:line_icons/line_icons.dart';
import 'package:upi_india/upi_india.dart';

class PaymentMethods extends StatelessWidget {
  final double amount;
  final expDate;
  final monthYear;
  final isTenant;

  PaymentMethods({this.amount, this.expDate, this.monthYear, this.isTenant});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        PaymentMethodTile(
          isTenant: isTenant,
          monthYear: monthYear,
          amount: amount,
          expDate: expDate,
          title: 'GooglePay',
          leadingIcon: Icon(
            LineIcons.google_wallet,
            color: Colors.blue,
          ),
          app: UpiApp.GooglePay,
        ),
        PaymentMethodTile(
          isTenant: isTenant,
          monthYear: monthYear,
          amount: amount,
          expDate: expDate,
          title: 'PhonePe',
          leadingIcon: Icon(
            LineIcons.paypal,
            color: Colors.deepPurpleAccent,
          ),
          app: UpiApp.PhonePe,
        ),
        PaymentMethodTile(
          isTenant: isTenant,
          monthYear: monthYear,
          amount: amount,
          expDate: expDate,
          title: 'MiPay',
          leadingIcon: Icon(
            LineIcons.money,
            color: Colors.orange,
          ),
          app: UpiApp.MiPay,
        ),
        PaymentMethodTile(
          isTenant: isTenant,
          monthYear: monthYear,
          amount: amount,
          expDate: expDate,
          title: 'PayTM',
          leadingIcon: Icon(
            LineIcons.bank,
            color: Colors.lightBlueAccent,
          ),
          app: UpiApp.PayTM,
        ),
        PaymentMethodTile(
          isTenant: isTenant,
          monthYear: monthYear,
          amount: amount,
          expDate: expDate,
          title: 'AmazonPay',
          leadingIcon: Icon(
            LineIcons.amazon,
            color: Colors.black,
          ),
          app: UpiApp.AmazonPay,
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
  final monthYear;
  final isTenant;

  PaymentMethodTile(
      {this.title,
      this.leadingIcon,
      this.amount,
      this.expDate,
      this.app,
      this.monthYear,
      this.isTenant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        PayUsingUpi(
            monthYear: monthYear,
            app: app,
            amount: amount,
            expDate: expDate,
            isTenant: isTenant);
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
      height: MediaQuery
          .of(context)
          .size
          .height * 0.38,
      width: MediaQuery
          .of(context)
          .size
          .width * 0.8,
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
                fontSize: 25,
              ),
            ),
            Text(
              payAmount,
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
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
