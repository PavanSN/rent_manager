import 'package:flutter/material.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class SelfQRCode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "QR Code",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: MyQrCode(),
    );
  }
}

class MyQrCode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          StateBuilder(
            models: [Injector.get<UserDetails>()],
            builder: (context, _) {
              return Hero(
                tag: 'qrCode',
                child: QrImage(
                  data: Injector.get<UserDetails>().uid,
                  size: MediaQuery.of(context).size.width * 0.7,
                ),
              );
            },
          ),
          Text(
            "This code should be scanned by your home owner with Home Manager app",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
