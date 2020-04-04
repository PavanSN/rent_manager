import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:upi_india/upi_india.dart';

String myUpiId = 'pavansn2000@ybl';

class PayUsingUpi {
  final double amount;
  final String monthYear;
  final bool isTenant;
  final int expDate;
  final String app;

  PayUsingUpi({
    this.amount,
    this.monthYear,
    this.expDate,
    this.isTenant,
    this.app,
  }) {
    initTxn(app);
  }

  initTxn(app) async {
    UpiIndia upi;

    upi = UpiIndia(
      app: app,
      receiverUpiId: myUpiId,
      transactionNote: 'Subscription Fee',
      amount: amount,
      receiverName: 'To Owner',
    );

    return txnDetails(await upi.startTransaction());
  }

  txnDetails(txn) {
    Fluttertoast.showToast(msg: txn);
    var response = UpiIndiaResponse(txn);
    print(
        response.status + '=================================================');
    if (response.status == 'success' || response.status == 'SUCCESS') {
      handleSuccess(response.transactionId, monthYear, isTenant, expDate);
    }
  }

  handleSuccess(txnId, monthYear, isTenant, expDate) {
    print(monthYear);

    Firestore.instance
        .document('users/${Injector.get<UserDetails>().uid}')
        .updateData({
      'expDate': expDate,
    });
  }
}
