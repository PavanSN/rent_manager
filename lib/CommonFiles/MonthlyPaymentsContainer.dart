import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getflutter/components/button/gf_button.dart';
import 'package:getflutter/components/list_tile/gf_list_tile.dart';
import 'package:home_manager/Models/TabPressed.dart';
import 'package:line_icons/line_icons.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'CommonWidgetsAndData.dart';

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
            month: DateTime.now().month,
            year: DateTime.now().year,
            tenantDocRef: tenantDocRef,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          StateBuilder(
            models: [Injector.get<TabPressed>(context: context)],
            builder: (context, _) {
              return Expanded(
                flex: 8,
                child: MonthsWithPaymentTile(
                  year: Injector.get<TabPressed>(context: context).yearPressed,
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
        onTap: (index) => Injector.get<TabPressed>(context: context)
            .yearTapped(accCreated + index),
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
  final tenantDocRef;

  MonthsWithPaymentTile({this.year, this.tenantDocRef});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 12,
      itemBuilder: (context, index) {
        return PayTile(
          month: index + 1,
          year: year,
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
  final DocumentReference tenantDocRef;

  PayTile({this.month, this.year, this.tenantDocRef});

  @override
  Widget build(BuildContext context) {
    final String monthYear = month.toString() + year.toString();
    return GestureDetector(
      onTap: () {
        bottomSheet(
          context,
          UpdatePayment(
            tenantDocRef: tenantDocRef,
            monthYear: monthYear,
          ),
          'Did Tenant pay rent on ${nameOfMonth(month)} $year',
        );
      },
      child: Card(
        child: GFListTile(
          color: Colors.white,
          title: Text(
            '${nameOfMonth(month)} $year ${DateTime.now().month == month && DateTime.now().year == year ? '(This Month)' : ''}',
          ),
          icon: StreamBuilder(
            stream:
                streamDoc('users/${tenantDocRef.documentID}/payments/payments'),
            builder: (context, doc) {
              try {
                return PayStatus(
                  status: getStatus(month, year, doc),
                  monthYear: monthYear,
                  tenantDocRef: tenantDocRef,
                );
              } catch (e) {
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
  final DocumentReference tenantDocRef;

  PayStatus({this.status, this.monthYear, this.tenantDocRef});

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
          Icon(
            Icons.close,
            color: Colors.red,
          ),
        ],
      );
    }
    return SizedBox();
  }
}

//============================= Trailing icon button ========================//
