import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getflutter/components/list_tile/gf_list_tile.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/Models/TabPressed.dart';
import 'package:line_icons/line_icons.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class TenantPayments extends StatelessWidget {
  final DocumentReference tenantDocRef;
  final AsyncSnapshot tenantDoc;

  TenantPayments({this.tenantDoc, this.tenantDocRef});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tenantDoc.data['name'],
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: MonthlyPaymentsVisibility(
        tenantDoc: tenantDoc,
        tenantDocRef: tenantDocRef,
      ),
    );
  }
}

class MonthlyPaymentsVisibility extends StatelessWidget {
  final AsyncSnapshot tenantDoc;
  final tenantDocRef;

  MonthlyPaymentsVisibility({this.tenantDoc, this.tenantDocRef});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Tabs(
            accCreated: tenantDoc.data['accCreated'],
          ),
        ),
        SizedBox(height: MediaQuery
            .of(context)
            .size
            .height * 0.01),
        PayTile(
          month: DateTime
              .now()
              .month,
          year: DateTime
              .now()
              .year,
          tenantDocRef: tenantDocRef,
        ),
        SizedBox(height: MediaQuery
            .of(context)
            .size
            .height * 0.01),
        StateBuilder(
          models: [Injector.get<TabPressed>()],
          builder: (context, _) {
            return Expanded(
              flex: 8,
              child: MonthsWithPaymentTile(
                  year: Injector
                      .get<TabPressed>()
                      .yearPressed ??
                      DateTime
                          .now()
                          .year,
                  tenantDocRef: tenantDocRef),
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
  var thisYear = DateTime
      .now()
      .year;
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
    return Column(
      children: <Widget>[
        Card(
          child: GFListTile(
            color: Colors.white,
            title: Text(
              '${nameOfMonth(month)} $year ${DateTime
                  .now()
                  .month == month && DateTime
                  .now()
                  .year == year ? '(This Month)' : ''}',
            ),
            icon: StreamBuilder(
              stream: streamDoc(
                  'users/${tenantDocRef.documentID}/payments/${Injector
                      .get<TabPressed>()
                      .yearPressed}'),
              builder: (context, tenantPaymentDoc) {
                try {
                  return _PayStatus(
                      status: getStatus(
                          month, year, tenantPaymentDoc.data[month.toString()]),
                      tenantDocRef: tenantDocRef);
                } catch (e) {
                  print(
                      'error in mnthswithpaymenttile paytile ' + e.toString());
                  return Text('Loading...');
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ============================= Pay Tile ==================================//

getStatus(month, year, paymentMonthInDB) {
  if (month < DateTime
      .now()
      .month &&
      year == DateTime
          .now()
          .year &&
      paymentMonthInDB == '') {
    return 'due';
  } else if (month >= DateTime
      .now()
      .month &&
      year == DateTime
          .now()
          .year &&
      paymentMonthInDB == '') {
    return 'unpaid';
  } else if (paymentMonthInDB != null) {
    return 'paid';
  } else
    return 'unpaid';
}

//============================= Trailing icon button ========================//

class _PayStatus extends StatelessWidget {
  final String status;
  final DocumentReference tenantDocRef;

  _PayStatus({this.status, this.tenantDocRef});

  @override
  Widget build(BuildContext context) {
    if (status == 'due') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            LineIcons.warning,
            color: Colors.red,
          ),
          SizedBox(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.05,
          ),
          PayButton(
            color: Colors.red,
          )
        ],
      );
    } else if (status == 'paid') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            LineIcons.check,
            color: Colors.green,
          ),
          SizedBox(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.05,
          ),
        ],
      );
    } else if (status == 'unpaid') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.05,
          ),
          PayButton(
            color: Colors.green,
            tenantDocRef: tenantDocRef,
          )
        ],
      );
    }
    return SizedBox();
  }
}

class PayButton extends StatelessWidget {
  final Color color;
  final DocumentReference tenantDocRef;

  PayButton({this.color, this.tenantDocRef});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: tenantDocRef.get(),
      builder: (context, tenantDoc) {
        try {
          return RaisedButton(
            onPressed: () => null,
            child: Text(tenantDoc.data['rent']),
            color: color,
          );
        } catch (e) {
          print(e.toString() + 'in payButton');
          return Text('Loading...');
        }
      },
    );
  }
}

//============================= Trailing icon button ========================//
