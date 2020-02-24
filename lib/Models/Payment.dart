import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'UserDetails.dart';
import 'package:cloud_functions/cloud_functions.dart';

class Payment {
  Razorpay razorpay;
  final String amount;
  final String monthYear;
  final bool isTenant;

  Payment({
    this.monthYear,
    this.isTenant,
    this.amount,
  }) {
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    razorpay.open({
      'key': 'rzp_test_BzQ1k3PY3WoVUJ',
      'amount': double.parse(amount) * 100,
      'name': 'Rent Manager',
      'description': 'Pay Rent',
      'payment_capture': true,
      'handler': CloudFunctions.instance
          .getHttpsCallable(functionName: 'capturePayments')
          .call({'req':, 'res':}),
      'prefill': {'email': Injector
          .get<UserDetails>()
          .email}
    });
  }

  _handlePaymentSuccess(PaymentSuccessResponse response) {
    var paymentId = response.paymentId;
    Fluttertoast.showToast(msg: paymentId);
    ;
  }

  _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: response.walletName);
  }

  _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: response.message);
  }
}
