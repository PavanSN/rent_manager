import 'package:flutter/material.dart';
import 'package:getflutter/components/list_tile/gf_list_tile.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/Models/RazorpayPayments.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:line_icons/line_icons.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

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
                  'users/${Injector
                      .get<UserDetails>()
                      .uid}/payments/payments'),
              builder: (context, paymentDoc) {
                try {
                  return _PayStatus(
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
  if (month < DateTime.now().month &&
      year == DateTime.now().year &&
      paymentMonthInDB[monthYear] == '') {
    return 'due';
  } else if (month >= DateTime.now().month &&
      year == DateTime.now().year &&
      paymentMonthInDB[monthYear] == '') {
    return 'unpaid';
  } else if (paymentMonthInDB[monthYear] != null) {
    return 'paid';
  } else
    return 'unpaid';
}

//============================= Trailing icon button ========================//

class _PayStatus extends StatelessWidget {
  final String status;
  final String monthYear;

  _PayStatus({this.status, this.monthYear});

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
            width: MediaQuery.of(context).size.width * 0.05,
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
            color: Colors.green,
            monthYear: monthYear,
          )
        ],
      );
    }
    return SizedBox();
  }
}

class PayButton extends StatelessWidget {
  final Color color;
  final monthYear;

  PayButton({this.color, this.monthYear});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureDoc('users/${Injector
          .get<UserDetails>()
          .uid}'),
      builder: (context, tenantDoc) {
        try {
          return RaisedButton(
            onPressed: () {
              print(monthYear);
              return RazorpayPayments(
                  rent: double.parse(tenantDoc.data['rent']),
                  monthYear: monthYear)
                  .orderPayment();
            },
            child: Text('Pay ${tenantDoc.data['rent']}'),
            color: color,
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
