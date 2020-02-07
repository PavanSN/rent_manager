import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getflutter/components/list_tile/gf_list_tile.dart';
import 'package:home_manager/Models/PayUsingUpi.dart';
import 'package:home_manager/Models/TabPressed.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:line_icons/line_icons.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'CommonWidgetsAndData.dart';

class MonthlyPayments extends StatelessWidget {
  final bool didTenantGetHome;
  final AsyncSnapshot tenantDoc;
  final DocumentReference tenantDocRef;

  MonthlyPayments({this.didTenantGetHome, this.tenantDoc, this.tenantDocRef});

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
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          StateBuilder(
            models: [Injector.get<TabPressed>()],
            builder: (context, _) {
              return Expanded(
                flex: 8,
                child: MonthsWithPaymentTile(
                  year: Injector.get<TabPressed>().yearPressed ??
                      DateTime.now().year,
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
    return Column(
      children: <Widget>[
        Card(
          child: GFListTile(
            color: Colors.white,
            title: Text(
              '${nameOfMonth(month)} $year ${DateTime.now().month == month && DateTime.now().year == year ? '(This Month)' : ''}',
            ),
            icon: StreamBuilder(
              stream: streamDoc(
                  'users/${Injector.get<UserDetails>().uid}/payments/payments'),
              builder: (context, paymentDoc) {
                try {
                  return PayStatus(
                    status: getStatus(month, year, paymentDoc.data),
                    monthYear: monthYear,
                  );
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
  String monthYear = month.toString() + year.toString();
  if (paymentMonthInDB[monthYear] == null) {
    return 'unpaid';
  } else {
    return 'paid';
  }
}

//============================= Trailing icon button ========================//

class PayStatus extends StatelessWidget {
  final String status;
  final String monthYear;

  PayStatus({this.status, this.monthYear});

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
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.05,
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
          )
        ],
      );
    }
    return SizedBox();
  }
}

class PayButton extends StatelessWidget {
  final monthYear;

  PayButton({this.monthYear});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureDoc('users/${Injector.get<UserDetails>().uid}'),
      builder: (context, tenantDoc) {
        try {
          return RaisedButton(
            onPressed: () {
              PayUsingUpi(
                amount: double.parse(tenantDoc.data['rent']),
                monthYear: monthYear,
                receiverUpi: tenantDoc.data['ownerUpi'],
              );
            },
            child: Text('Pay ${tenantDoc.data['rent']}'),
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
