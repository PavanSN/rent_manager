import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:upi_india/upi_india.dart';

class PayUsingUpi {
  final double amount;
  final String monthYear;
  final bool isTenant;
  final int expDate;
  final String app;
  final String upiId;

  PayUsingUpi({
    this.upiId,
    this.amount,
    this.monthYear,
    this.expDate,
    this.isTenant,
    this.app,
  }) {
    initTxn(app);
  }

  initTxn(app) async {
    UpiIndia upi = UpiIndia();

    return txnDetails(await upi.startTransaction(
      app: app,
      receiverUpiId: upiId,
      amount: amount,
      receiverName: 'To Owner',
      transactionNote: 'Payment using Rent Manager',
    ));
  }

  txnDetails(UpiResponse txn) {
    BotToast.showSimpleNotification(title: txn.status);
    if (txn.status == 'success' || txn.status == 'SUCCESS') {
      handleSuccess(txn.transactionId, monthYear, isTenant, expDate);
    } else {
      BotToast.showSimpleNotification(title: txn.error);
    }
  }

  handleSuccess(String txnId, String monthYear, bool isTenant, int expDate) {
    if (isTenant) {
      Firestore.instance
          .document(
              'users/${Injector.get<UserDetails>().uid}/payments/payments')
          .updateData({monthYear: txnId});
    } else {
      myDoc().updateData({
        'expDate': expDate,
      });
    }
  }
}
