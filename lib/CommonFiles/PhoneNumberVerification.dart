import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

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
                  BotToast.showSimpleNotification(
                      title: 'OTP Sent, trying to read OTP');
                  FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: phoneNo.phoneNumber,
                    timeout: Duration(seconds: 60),
                    verificationCompleted: (AuthCredential credential) async {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Injector.get<UserDetails>().getDetails();
                      FirebaseAuth.instance.currentUser().then((value) {
                        value.updatePhoneNumberCredential(credential);
                        myDoc().updateData({'phoneNum': phoneNo.phoneNumber});
                        BotToast.showSimpleNotification(
                            title: 'Phone verification successfully completed');
                      });
                    },
                    verificationFailed: (error) {
                      BotToast.showSimpleNotification(title: error.message);
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
                                    PhoneAuthProvider.getCredential(
                                        verificationId: verId, smsCode: otp);
                                FirebaseAuth.instance
                                    .currentUser()
                                    .then((value) {
                                  value
                                      .updatePhoneNumberCredential(credential)
                                      .then((value) {
                                    myDoc().updateData(
                                        {'phoneNum': phoneNo.phoneNumber});
                                  });
                                  Injector.get<UserDetails>().getDetails();
                                  Navigator.pop(context);
                                });
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
