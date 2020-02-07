import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:upi_india/upi_india.dart';

class PayUsingUpi {
  final double amount;
  final String monthYear;
  final receiverUpi;
  final bool isTenant;
  final int expDate;
  final String app;

  PayUsingUpi({
    this.amount,
    this.monthYear,
    this.receiverUpi,
    this.expDate,
    this.isTenant,
    this.app,
  }) {
    payUsing(app);
  }

  payUsing(app) async {
    UpiIndia upi = UpiIndia(
      app: app,
      receiverUpiId: receiverUpi,
      receiverName: null,
      transactionNote: 'Rent',
      amount: amount,
    );
    Future transaction = upi.startTransaction();

    var response = UpiIndiaResponse(await transaction);

    if (response.status == 'success') {
      handleSuccess(response.transactionId, monthYear, isTenant, expDate);
    } else {
      Fluttertoast.showToast(msg: await transaction);
    }

    Fluttertoast.showToast(
      msg: await transaction,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
    );
  }
}

handleSuccess(txnId, monthYear, isTenant, expDate) {
  if (isTenant) {
    Firestore.instance
        .document('users/${Injector.get<UserDetails>().uid}/payments/payments')
        .updateData({
      monthYear: txnId,
    });
  } else if (!isTenant) {
    Firestore.instance
        .document('users/${Injector.get<UserDetails>().uid}')
        .updateData({
      'expDate': expDate,
    });
  }
}
