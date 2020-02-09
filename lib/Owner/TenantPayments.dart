import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
