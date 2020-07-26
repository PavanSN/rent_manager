import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/Models/TabPressed.dart';
import 'package:line_icons/line_icons.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'CommonWidgetsAndData.dart';
import 'PaymentMethodsBtmSheet.dart';

class MonthlyPayments extends StatelessWidget {
  final AsyncSnapshot myDocSnap;

  MonthlyPayments({
    this.myDocSnap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Tabs(
            accCreated: myDocSnap.data['accCreated'],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        PayTile(
          month: DateTime.now().month,
          year: DateTime.now().year,
        ),
        StateBuilder(
          observe: () => Injector.get<TabPressed>(),
          builder: (context, _) {
            return Expanded(
              flex: 8,
              child: MonthsWithPaymentTile(
                  year: Injector.get<TabPressed>().yearPressed),
            );
          },
        ),
      ],
    );
  }
}

class Tabs extends StatelessWidget {
  final int accCreated;

  Tabs({this.accCreated});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: getTabs(accCreated).length - 1,
      length: getTabs(accCreated).length,
      child: TabBar(
        onTap: (index) =>
            Injector.get<TabPressed>().yearTapped(accCreated + index),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.red,
        indicatorColor: Colors.red,
        unselectedLabelColor: Color(0xff5f6368),
        isScrollable: true,
        tabs: getTabs(accCreated),
      ),
    );
  }
}

List<Tab> getTabs(int accCreated) {
  var thisYear = DateTime.now().year;
  List<Tab> tabs = [];

  if (accCreated == thisYear) {
    return [
      Tab(
        text: thisYear.toString(),
      )
    ];
  } else if (accCreated < thisYear) {
    int yearDifference = thisYear - accCreated;
    for (int i = 0; i <= yearDifference; i++) {
      tabs.add(Tab(
        text: (accCreated + i).toString(),
      ));
    }
    return tabs;
  } else
    return [
      Tab(
        text: 'You need to be a tenant in the house',
      )
    ];
}

class MonthsWithPaymentTile extends StatelessWidget {
  final int year;

  MonthsWithPaymentTile({this.year});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 12,
      itemBuilder: (context, index) {
        return PayTile(
          month: index + 1,
          year: year,
        );
      },
    );
  }
}

// ============================= Pay Tile ==================================//

class PayTile extends StatelessWidget {
  final int month;
  final int year;

  PayTile({this.month, this.year});

  @override
  Widget build(BuildContext context) {
    final String monthYear = month.toString() + year.toString();
    return Card(
      elevation: 5,
      child: ListTile(
        onTap: () {
          BotToast.showSimpleNotification(title: 'Tenant Cannot edit payments');
        },
        title: Text(
          '${nameOfMonth(month)} $year ${DateTime.now().month == month && DateTime.now().year == year ? '(This Month)' : ''}',
          style: Theme.of(context).textTheme.overline.copyWith(fontSize: 15),
        ),
        trailing: StreamBuilder(
          stream: streamDoc('users/${myDoc().documentID}/payments/payments'),
          builder: (context, doc) {
            try {
              return PayStatus(
                status: getStatus(month, year, doc),
                monthYear: monthYear,
                myDocRef: myDoc(),
              );
            } catch (e) {
              return Text('Loading...');
            }
          },
        ),
      ),
    );
  }
}

class PayStatus extends StatelessWidget {
  final String status;
  final String monthYear;
  final DocumentReference myDocRef;

  PayStatus({this.status, this.monthYear, this.myDocRef});

  @override
  Widget build(BuildContext context) {
    if (status == 'paid') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            LineIcons.check,
            color: Colors.green,
          ),
        ],
      );
    } else if (status == 'unpaid') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.05,
          ),
          PayButton(
            monthYear: monthYear,
            tenantDocRef: myDocRef,
          ),
        ],
      );
    }
    return SizedBox();
  }
}

class PayButton extends StatelessWidget {
  final monthYear;
  final DocumentReference tenantDocRef;

  PayButton({this.monthYear, this.tenantDocRef});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: tenantDocRef.snapshots(),
      builder: (context, tenantDoc) {
        try {
          var rent = tenantDoc.data['rent'];
          return Row(
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  bottomSheet(
                    context,
                    PaymentMethods(
                      monthYear: monthYear,
                      amount: double.parse(rent),
                    ),
                    'Pay Using',
                  );
                },
                child: Text(
                  'Pay ₹$rent',
                ),
                color: Colors.green,
              ),
            ],
          );
        } catch (e) {
          print(e.toString() + 'in paybutton tenant');
          return Text('Loading...');
        }
      },
    );
  }
}

class UpdatePayment extends StatelessWidget {
  final String monthYear;

  UpdatePayment({this.monthYear});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
            child: Text('Paid'),
            color: Colors.green,
            onPressed: () {
              myDoc().collection('payments').document('payments').updateData({
                monthYear: 'paid',
              }).then((_) {
                Navigator.pop(context);
              });
            }),
        RaisedButton(
            child: Text('Not Paid'),
            color: Colors.red,
            onPressed: () {
              myDoc().collection('payments').document('payments').updateData({
                monthYear: null,
              }).then((_) {
                Navigator.pop(context);
              });
            }),
      ],
    );
  }
}

// ============================= Pay Tile ==================================//

getStatus(month, year, AsyncSnapshot paymentDoc) {
  String monthYear = month.toString() + year.toString();

  if (paymentDoc.data[monthYear] != null) {
    return 'paid';
  } else {
    return 'unpaid';
  }
}

//============================= Trailing icon button ========================//

//class PayStatus extends StatelessWidget {
//  final String status;
//  final String monthYear;
//  final DocumentReference myDocRef;
//
//  PayStatus({this.status, this.monthYear, this.myDocRef});
//
//  @override
//  Widget build(BuildContext context) {
//    if (status == 'paid') {
//      return Row(
//        mainAxisSize: MainAxisSize.min,
//        children: <Widget>[
//          Icon(
//            LineIcons.check,
//            color: Colors.green,
//          ),
//        ],
//      );
//    } else if (status == 'unpaid') {
//      return Row(
//        mainAxisSize: MainAxisSize.min,
//        children: <Widget>[
//          SizedBox(
//            width: MediaQuery.of(context).size.width * 0.05,
//          ),
//          Icon(
//            Icons.close,
//            color: Colors.red,
//          ),
//        ],
//      );
//    }
//    return SizedBox();
//  }
//}

//============================= Trailing icon button ========================//
