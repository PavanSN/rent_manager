import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:upi_india/upi_india.dart';

class PayUsingUpi {
  final double amount;
  final String monthYear;
  final receiverUpi;
  final int expDate;
  final String app;

  PayUsingUpi({
    this.amount,
    this.monthYear,
    this.receiverUpi,
    this.expDate,
    this.app,
  }) {
    initTxn(app);
  }

  initTxn(app) async {
    UpiIndia upi;

    upi = UpiIndia();

    return txnDetails(await upi.startTransaction(
      app: app,
      receiverUpiId: receiverUpi,
      transactionNote: 'Rent',
      amount: amount,
      receiverName: 'To Owner',
    ));
  }

  txnDetails(txn) {
    BotToast.showSimpleNotification(title: txn);
    var response = UpiResponse(txn);
    print(
        response.status + '=================================================');
    if (response.status == 'success' || response.status == 'SUCCESS') {
      handleSuccess(response.transactionId, monthYear, expDate);
    }
  }

  handleSuccess(txnId, monthYear, expDate) {
    print(monthYear);

    Firestore.instance
        .document('users/${Injector.get<UserDetails>().uid}/payments/payments')
        .updateData({
      monthYear: txnId,
    });
  }
}
