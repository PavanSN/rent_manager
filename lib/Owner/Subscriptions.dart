import 'package:flutter/material.dart';

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
          payAmount: "\$3 /month",
          onPressed: () => null,
        ),
        SizedBox(
          height: 15,
        ),
        BeautifulCard(
          color: Colors.orange,
          pay: "Pay Yearly",
          payAmount: "\$35 /year",
          onPressed: () => null,
        ),
      ],
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
