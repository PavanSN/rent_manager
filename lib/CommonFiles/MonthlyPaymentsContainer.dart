import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/Models/TabPressed.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'CommonWidgetsAndData.dart';
import 'PaymentMethodsBtmSheet.dart';

class MonthlyPayments extends StatelessWidget {
  final AsyncSnapshot tenantSnap;
  final bool isTenant;
  final int rentAmnt;

  MonthlyPayments({
    this.tenantSnap,
    this.isTenant,
    this.rentAmnt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Tabs(
            accCreated: tenantSnap.data['accCreated'],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          PayTile(
            month: DateTime.now().month,
            year: DateTime.now().year,
            isTenant: isTenant,
            tenantSnap: tenantSnap,
            rentAmnt: rentAmnt,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          StateBuilder(
            observe: () => Injector.get<TabPressed>(),
            builder: (context, _) {
              return Expanded(
                flex: 8,
                child: MonthsWithPaymentTile(
                  year: Injector.get<TabPressed>().yearPressed,
                  isTenant: isTenant,
                  tenantSnap: tenantSnap,
                  rentAmnt: rentAmnt,
                ),
              );
            },
          ),
        ],
      ),
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
  final bool isTenant;
  final AsyncSnapshot tenantSnap;
  final int rentAmnt;

  MonthsWithPaymentTile(
      {this.year, this.isTenant, this.tenantSnap, this.rentAmnt});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 12,
      itemBuilder: (context, index) {
        return PayTile(
          tenantSnap: tenantSnap,
          month: index + 1,
          year: year,
          isTenant: isTenant,
          rentAmnt: rentAmnt,
        );
      },
    );
  }
}

// ============================= Pay Tile ==================================//

class PayTile extends StatelessWidget {
  final int month;
  final int year;
  final bool isTenant;
  final AsyncSnapshot tenantSnap;
  final int rentAmnt;

  PayTile(
      {this.month, this.year, this.isTenant, this.tenantSnap, this.rentAmnt});

  @override
  Widget build(BuildContext context) {
    final String monthYear = month.toString() + year.toString();
    return Card(
      elevation: 5,
      child: ListTile(
        onTap: () {
          if (isTenant) {
            BotToast.showSimpleNotification(
                title: 'Tenant Cannot edit payments');
          } else {
            bottomSheet(
              context,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.green,
                    child: Text('Paid'),
                    onPressed: () {
                      Firestore.instance
                          .document(
                          'users/${tenantSnap.data['uid']}/payments/payments')
                          .updateData({monthYear: monthYear});
                      Navigator.pop(context);
                    },
                  ),
                  RaisedButton(
                    color: Colors.red,
                    child: Text('Not paid'),
                    onPressed: () {
                      Firestore.instance
                          .document(
                          'users/${tenantSnap.data['uid']}/payments/payments')
                          .updateData({monthYear: FieldValue.delete()});
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
              'Tenant Paid on ${nameOfMonth(month)} $year...?',
            );
          }
        },
        title: Text(
          '${nameOfMonth(month)} $year ${DateTime.now().month == month && DateTime.now().year == year ? '(This Month)' : ''}',
          style: Theme.of(context).textTheme.overline.copyWith(fontSize: 15),
        ),
        trailing: StreamBuilder(
          stream: isTenant
              ? streamDoc('users/${myDoc().documentID}/payments/payments')
              : Firestore.instance
              .document('users/${tenantSnap.data['uid']}/payments/payments')
              .snapshots(),
          builder: (context, paymentDoc) {
            try {
              return PayStatus(
                status: getStatus(month, year, paymentDoc),
                monthYear: monthYear,
                isTenant: isTenant,
                rentAmnt: rentAmnt,
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

class PayButton extends StatelessWidget {
  final monthYear;
  final isTenant;

  PayButton({this.monthYear, this.isTenant});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: myDoc().snapshots(),
      builder: (context, doc) {
        try {
          var rent = doc.data['rent'];
          return RaisedButton(
            onPressed: () {
              bottomSheet(
                context,
                PaymentMethods(
                  monthYear: monthYear,
                  amount: double.parse(rent.toString()),
                  isTenant: isTenant,
                ),
                'Pay Using',
              );
            },
            child: Text(
              'Pay ₹$rent',
            ),
            color: Colors.deepPurpleAccent,
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

class PayStatus extends StatelessWidget {
  final String status;
  final String monthYear;
  final bool isTenant;
  final int rentAmnt;

  PayStatus({this.status, this.monthYear, this.isTenant, this.rentAmnt});

  @override
  Widget build(BuildContext context) {
    print(status);
    if (status == 'paid') {
      return Icon(
        Icons.done_all,
        color: Colors.green,
      );
    } else {
      if (isTenant) {
        return PayButton(monthYear: monthYear, isTenant: isTenant);
      } else {
        return Icon(
          Icons.close,
          color: Colors.red,
        );
      }
    }
  }
}

//============================= Trailing icon button ========================//
