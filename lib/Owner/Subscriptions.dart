import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/PaymentMethodsBtmSheet.dart';

double payAmountMonth = 50;
double payAmountYear = 500;

class Subscriptions extends StatelessWidget {
  final subscriptionPeriodOverTextVisible;
  final expDate;

  Subscriptions({this.subscriptionPeriodOverTextVisible, this.expDate});

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
        child: SubscriptionsBody(
          subscriptionPeriodOverTextVisible: subscriptionPeriodOverTextVisible,
          expDate: expDate,
        ),
      ),
    );
  }
}

class SubscriptionsBody extends StatelessWidget {
  final subscriptionPeriodOverTextVisible;
  final expDate;

  SubscriptionsBody({this.subscriptionPeriodOverTextVisible, this.expDate});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        SizedBox(
          height: 15,
        ),
        Visibility(
          visible: subscriptionPeriodOverTextVisible,
          child: Text(
            'Your subscription period got over on ${DateTime
                .fromMillisecondsSinceEpoch(
                expDate)}, Please re-subscribe to keep your app running',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        BeautifulCard(
          color: Colors.deepPurple,
          pay: "Pay Monthly",
          payAmount: "₹$payAmountMonth / 30 Days",
          onPressed: () {
            var date = DateTime.now();
            var expDate = DateTime(date.year, date.month, date.day + 30)
                .millisecondsSinceEpoch;
            bottomSheet(
              context,
              PaymentMethods(
                monthYear: null,
                amount: payAmountMonth,
                expDate: expDate,
                isTenant: false,
              ),
              'Pay Using',
            );
          },
        ),
        SizedBox(
          height: 15,
        ),
//        BeautifulCard(
//          color: Colors.orange,
//          pay: "Pay Yearly",
//          payAmount: "₹$payAmountYear / 365 Days",
//          onPressed: () {
//            var date = DateTime.now();
//            var expDate = DateTime(date.year, date.month, date.day + 365)
//                .millisecondsSinceEpoch;
//
//            bottomSheet(
//              context,
//              PaymentMethods(
//                amount: payAmountYear,
//                expDate: expDate,
//                isTenant: false,
//              ),
//              'Pay Using',
//            );
//          },
//        ),
      ],
    );
  }
}

