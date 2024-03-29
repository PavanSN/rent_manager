import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sms_autofill/sms_autofill.dart';

PhoneNumber phoneNo;

class PhoneNumVerificationUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: InternationalPhoneNumberInput(
                  initialValue: PhoneNumber(
                    phoneNumber: '',
                    dialCode: '+91',
                    isoCode: 'IN',
                  ),
                  hintText: "Phone Number",
                  onInputChanged: (phone) => phoneNo = phone,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              RaisedButton(
                onPressed: () {
                  String verId;
                  Fluttertoast.showToast(msg: 'OTP Sent, trying to read OTP');
                  FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: phoneNo.phoneNumber,
                    timeout: Duration(seconds: 60),
                    verificationCompleted: (AuthCredential credential) async {
                      Navigator.of(context).pop();
                      FirebaseAuth.instance.currentUser
                          .updatePhoneNumber(credential);
                      myDoc.update({'phoneNum': phoneNo.phoneNumber});
                      Fluttertoast.showToast(
                          msg: 'Phone verification successfully completed');
                    },
                    verificationFailed: (error) {
                      Fluttertoast.showToast(msg: error.message);
                    },
                    codeSent: (verificationId, [forceResendingToken]) {
                      verId = verificationId;
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Enter OTP'),
                            content: PinFieldAutoFill(
                              onCodeSubmitted: (otp) async {
                                AuthCredential credential =
                                    PhoneAuthProvider.credential(
                                        verificationId: verId, smsCode: otp);
                                FirebaseAuth.instance.currentUser
                                    .updatePhoneNumber(credential)
                                    .then((value) {
                                  myDoc.update(
                                      {'phoneNum': phoneNo.phoneNumber});
                                });
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      );
                    },
                    codeAutoRetrievalTimeout: (verificationId) {
                      verId = verificationId;
                    },
                  );
                },
                color: Colors.red,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('Verify'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
