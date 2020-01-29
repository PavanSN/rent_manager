import 'package:flutter/material.dart';
import 'package:getflutter/components/list_tile/gf_list_tile.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
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
    return Column(
      children: <Widget>[
        Card(
          child: GFListTile(
            color: Colors.white,
            title: Text(
              '${nameOfMonth(month)} $year ${DateTime.now().month == month && DateTime.now().year == year ? '(This Month)' : ''}',
            ),
            icon: FutureBuilder(
              future: futureDoc(
                  'tenantPayments/${Injector.get<UserDetails>().uid}/payments/$year'),
              builder: (context, paymentDoc) {
                if (!paymentDoc.hasData) return Text('Loading');
                return _PayStatus(
                  status:
                      getStatus(month, year, paymentDoc.data[month.toString()]),
                );
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
  if (month < DateTime.now().month &&
      year == DateTime.now().year &&
      paymentMonthInDB == '') {
    return 'due';
  } else if (month >= DateTime.now().month &&
      year == DateTime.now().year &&
      paymentMonthInDB == '') {
    return 'unpaid';
  } else
    return 'paid';
}

//============================= Trailing icon button ========================//

class _PayStatus extends StatelessWidget {
  final String status;

  _PayStatus({this.status});

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
          )
        ],
      );
    }
    return SizedBox();
  }
}

class PayButton extends StatelessWidget {
  final Color color;

  PayButton({this.color});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => null,
      child: Text('Pay 7000'),
      color: color,
    );
  }
}

//============================= Trailing icon button ========================//
