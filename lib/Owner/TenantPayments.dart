import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
          "${tenantDoc.data['name']} (₹${tenantDoc.data['rent']})",
          style: Theme.of(context).textTheme.subtitle1,
        ),
        centerTitle: true,
      ),
      body: MonthlyPayments(
        tenantDoc: tenantDoc,
        didTenantGetHome: true,
        tenantDocRef: tenantDocRef,
      ),
    );
  }
}

class EditRent extends StatelessWidget {
  EditRent({this.tenantDocRef});

  final DocumentReference tenantDocRef;

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
  UpdateRent({this.tenantDocRef, this.rentAmountController});

  final TextEditingController rentAmountController;
  final DocumentReference tenantDocRef;

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
              child: CustomTextField(
                controller: rentAmountController,
                hintText: "Current Rent ₹${doc.data['rent']}",
                onSubmitted: (amt) {
                  tenantDocRef.updateData({'rent': amt});
                  BotToast.showSimpleNotification(
                      title:
                          'Rent amount for ${doc.data['name']} has changed to $amt');
                  Navigator.pop(context);
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