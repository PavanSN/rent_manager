import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getflutter/components/button/gf_button.dart';
import 'package:getflutter/components/list_tile/gf_list_tile.dart';
import 'package:home_manager/Models/TabPressed.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:line_icons/line_icons.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'CommonWidgetsAndData.dart';
import 'PaymentMethodsBtmSheet.dart';

class MonthlyPayments extends StatelessWidget {
  final bool didTenantGetHome;
  final AsyncSnapshot tenantDoc;
  final isTenant;
  final DocumentReference tenantDocRef;

  MonthlyPayments({
    this.didTenantGetHome,
    this.tenantDoc,
    this.isTenant,
    this.tenantDocRef,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: didTenantGetHome,
      replacement: Center(
        child: Text(
          'You need to tap on the qr button (Top Left) in order to register you as a tenant',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Tabs(
              accCreated: tenantDoc.data['accCreated'],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          PayTile(
            isTenant: isTenant,
            month: DateTime.now().month,
            year: DateTime.now().year,
            tenantDocRef: tenantDocRef,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          StateBuilder(
            models: [Injector.get<TabPressed>()],
            builder: (context, _) {
              return Expanded(
                flex: 8,
                child: MonthsWithPaymentTile(
                  year: Injector.get<TabPressed>().yearPressed,
                  isTenant: isTenant,
                  tenantDocRef: tenantDocRef,
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
  final tenantDocRef;

  MonthsWithPaymentTile({this.year, this.isTenant, this.tenantDocRef});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 12,
      itemBuilder: (context, index) {
        return PayTile(
          month: index + 1,
          year: year,
          isTenant: isTenant,
          tenantDocRef: tenantDocRef,
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
  final DocumentReference tenantDocRef;

  PayTile({this.month, this.year, this.isTenant, this.tenantDocRef});

  @override
  Widget build(BuildContext context) {
    final String monthYear = month.toString() + year.toString();
    return GestureDetector(
      onTap: () {
        if (!isTenant) {
          bottomSheet(
            context,
            UpdatePayment(
              tenantDocRef: tenantDocRef,
              monthYear: monthYear,
            ),
            'Did Tenant pay rent on ${nameOfMonth(month)} $year',
          );
        }
      },
      child: Card(
        child: GFListTile(
          color: Colors.white,
          title: Text(
            '${nameOfMonth(month)} $year ${DateTime.now().month == month && DateTime.now().year == year ? '(This Month)' : ''}',
          ),
          icon: StreamBuilder(
            stream: isTenant
                ? streamDoc(
                    'users/${Injector.get<UserDetails>().uid}/payments/payments')
                : streamDoc(
                    'users/${tenantDocRef.documentID}/payments/payments'),
            builder: (context, doc) {
              try {
                return PayStatus(
                  status: getStatus(month, year, doc, isTenant),
                  monthYear: monthYear,
                  tenantDocRef: tenantDocRef,
                  isTenant: isTenant,
                );
              } catch (e) {
                print('error in mnthswithpaymenttile paytile ' + e.toString());
                return Text('Loading...');
              }
            },
          ),
        ),
      ),
    );
  }
}

class UpdatePayment extends StatelessWidget {
  final DocumentReference tenantDocRef;
  final String monthYear;

  UpdatePayment({this.tenantDocRef, this.monthYear});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        GFButton(
            child: Text('Paid'),
            color: Colors.green,
            onPressed: () {
              tenantDocRef
                  .collection('payments')
                  .document('payments')
                  .updateData({
                monthYear: 'paid',
              }).then((_) {
                Navigator.pop(context);
              });
            }),
        GFButton(
            child: Text('Not Paid'),
            color: Colors.red,
            onPressed: () {
              tenantDocRef
                  .collection('payments')
                  .document('payments')
                  .updateData({
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

getStatus(month, year, AsyncSnapshot paymentDoc, isTenant) {
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
  final DocumentReference tenantDocRef;
  final isTenant;

  PayStatus({this.status, this.monthYear, this.tenantDocRef, this.isTenant});

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
          isTenant
              ? PayButton(
                  monthYear: monthYear,
                  tenantDocRef: tenantDocRef,
                  isTenant: isTenant,
                )
              : Icon(
                  Icons.close,
                  color: Colors.red,
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
  final isTenant;

  PayButton({this.monthYear, this.tenantDocRef, this.isTenant});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: tenantDocRef.snapshots(),
      builder: (context, tenantDoc) {
        try {
          var rent = tenantDoc.data['rent'];
          return RaisedButton(
            onPressed: () {
              bottomSheet(
                context,
                PaymentMethods(
                  monthYear: monthYear,
                  amount: double.parse(rent),
                  isTenant: isTenant,
                ),
                'Pay Using',
              );
            },
            child: Text(
              isTenant ? 'Pay ₹$rent' : 'Due ₹$rent',
            ),
            color: Colors.green,
          );
        } catch (e) {
          print(e.toString() + 'in paybutton tenant');
          return Text('Loading...');
        }
      },
    );
  }
}

//============================= Trailing icon button ========================//
