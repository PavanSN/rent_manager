import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_manager/CommonFiles/CommonWidgetsAndData.dart';
import 'package:home_manager/CommonFiles/MonthlyPaymentsContainer.dart';

class TenantPayments extends StatelessWidget {
  final AsyncSnapshot tenantDoc;
  final isTenant;
  final DocumentReference tenantDocRef;

  TenantPayments({
    this.tenantDoc,
    this.isTenant,
    this.tenantDocRef,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          EditRent(
            tenantDocRef: tenantDocRef,
          )
        ],
        title: Text(
          tenantDoc.data['name'],
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: MonthlyPayments(
        tenantDoc: tenantDoc,
        didTenantGetHome: true,
        isTenant: false,
        tenantDocRef: tenantDocRef,
      ),
    );
  }
}

class EditRent extends StatelessWidget {
  EditRent({this.tenantDocRef});

  DocumentReference tenantDocRef;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.mode_edit),
      onPressed: () {
        bottomSheet(
          context,
          UpdateRent(
            tenantDocRef: tenantDocRef,
          ),
          "Edit rent amount",
        );
      },
    );
  }
}

class UpdateRent extends StatelessWidget {
  UpdateRent({this.tenantDocRef});

  TextEditingController rentAmountController;
  DocumentReference tenantDocRef;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: tenantDocRef.get(),
      builder: (context,doc){
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: TextField(
                controller: rentAmountController,
                decoration: InputDecoration(labelText: "Current Rent ₹${doc.data['rent']}"),
                keyboardType: TextInputType.numberWithOptions(),
                onSubmitted: (amt) {
                  tenantDocRef.updateData({'rent': amt});
                  Fluttertoast.showToast(msg: 'Rent amount changed to $amt');
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

 getInitRentAmt(tenantDocRef){
   tenantDocRef.get().then((doc) {
     return doc.data['rent'].toString();
  });
}