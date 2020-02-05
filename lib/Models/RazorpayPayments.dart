import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'UserDetails.dart';

class RazorpayPayments {
  final double rent;
  final String monthYear;

  Razorpay razorPay = Razorpay();

  RazorpayPayments({this.rent, this.monthYear}) {
    addCustomer();
  }

  addCustomer() {
    razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  orderPayment() async {
    var options = {
      'key': 'rzp_test_6s4zuOnQ69HC3O',
      'amount': rent * 100,
      'name': Injector.get<UserDetails>().name,
      'description': 'Rent',
      'prefill': {
        'email': Injector.get<UserDetails>().email,
      },
      'external': {
        'wallets': ['phonepe']
      }
    };

    try {
      razorPay.open(options);
    } catch (e) {
      print(e);
    }
  }

  handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(msg: "Payment Success " + response.paymentId);
    Firestore.instance
        .document('users/${Injector.get<UserDetails>().uid}/payments/payments')
        .updateData({
      monthYear: response.paymentId,
    });
  }

  handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment Error" + response.message);
  }

  handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: 'External Wallet ' + response.walletName);
  }

  dispose() {
    razorPay.clear();
  }
}
