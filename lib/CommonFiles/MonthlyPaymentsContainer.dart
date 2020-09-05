import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_manager/Models/TabPressed.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'CommonWidgetsAndData.dart';
import 'PaymentMethodsBtmSheet.dart';

class MonthlyPayments extends StatelessWidget {
  final AsyncSnapshot<DocumentSnapshot> tenantSnap;
  final bool isTenant;
  final int rentAmnt;
  final bool isOffline;
  final String offlineTenantUid;

  MonthlyPayments({
    this.tenantSnap,
    this.isTenant,
    this.rentAmnt,
    this.isOffline,
    this.offlineTenantUid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          !isOffline
              ? '${tenantSnap.data.data()['name']}   ₹${tenantSnap.data.data()['rent']}/month'
              : '${tenantSnap.data.data()['name']}',
          style: TextStyle(color: Colors.black),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: <Widget>[
          Tabs(
            accCreated: tenantSnap.data.data()['accCreated'],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          PayTile(
            month: DateTime.now().month,
            year: DateTime.now().year,
            isTenant: isTenant,
            tenantSnap: tenantSnap,
            rentAmnt: rentAmnt,
            isOffline: isOffline,
            offlineTenantUid: offlineTenantUid,
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
                  isOffline: isOffline,
                  offlineTenantUid: offlineTenantUid,
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
  final AsyncSnapshot<DocumentSnapshot> tenantSnap;
  final int rentAmnt;
  final bool isOffline;
  final String offlineTenantUid;

  MonthsWithPaymentTile(
      {this.year,
      this.isTenant,
      this.tenantSnap,
      this.rentAmnt,
      this.isOffline,
      this.offlineTenantUid});

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
          isOffline: isOffline,
          offlineTenantUid: offlineTenantUid,
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
  final AsyncSnapshot<DocumentSnapshot> tenantSnap;
  final int rentAmnt;
  final bool isOffline;
  final String offlineTenantUid;

  PayTile({this.month,
    this.year,
    this.isTenant,
    this.tenantSnap,
    this.rentAmnt,
    this.isOffline,
    this.offlineTenantUid});

  @override
  Widget build(BuildContext context) {
    final String monthYear = month.toString() + year.toString();
    return Card(
      elevation: 5,
      child: ListTile(
        onTap: () {
          if (isTenant) {
            Fluttertoast.showToast(msg: 'Tenant Cannot edit payments');
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
                      !isOffline
                          ? FirebaseFirestore.instance
                          .doc(
                          'users/${tenantSnap.data
                              .data()['uid']}/payments/payments')
                          .update({monthYear: 'paid'})
                          : myDoc
                          .collection('offline')
                          .doc('$offlineTenantUid/payments/payments')
                          .update({monthYear: 'paid'});
                      Navigator.pop(context);
                    },
                  ),
                  RaisedButton(
                    color: Colors.red,
                    child: Text('Not paid'),
                    onPressed: () {
                      !isOffline
                          ? FirebaseFirestore.instance
                          .doc(
                          'users/${tenantSnap.data
                              .data()['uid']}/payments/payments')
                          .update({monthYear: FieldValue.delete()})
                          : myDoc
                          .collection('offline')
                          .doc('$offlineTenantUid/payments/payments')
                          .update({monthYear: FieldValue.delete()});
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
              ? streamDoc('users/${myDoc.id}/payments/payments')
              : !isOffline
              ? FirebaseFirestore.instance
              .doc(
              'users/${tenantSnap.data.data()['uid']}/payments/payments')
              .snapshots()
              : myDoc
              .collection('offline')
              .doc('$offlineTenantUid/payments/payments')
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> paymentDoc) {
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
      stream: myDoc.snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> doc) {
        try {
          var rent = doc.data.data()['rent'];
          var homeId = doc.data.data()['homeId'];
          var upiId;
          FirebaseFirestore.instance
              .doc('users/$homeId')
              .get()
              .then((value) => upiId = value.data()['upiId']);
          return RaisedButton(
            onPressed: () {
              bottomSheet(
                context,
                PaymentMethods(
                  monthYear: monthYear,
                  amount: double.parse(rent.toString()),
                  isTenant: isTenant,
                  upiId: upiId,
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
          return Text('Waiting...');
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
              myDoc.collection('payments').doc('payments').update({
                monthYear: 'paid',
              }).then((_) {
                Navigator.pop(context);
              });
            }),
        RaisedButton(
            child: Text('Not Paid'),
            color: Colors.red,
            onPressed: () {
              myDoc.collection('payments').doc('payments').update({
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

getStatus(month, year, AsyncSnapshot<DocumentSnapshot> paymentDoc) {
  String monthYear = month.toString() + year.toString();

  if (paymentDoc.data.data()[monthYear] != null) {
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
