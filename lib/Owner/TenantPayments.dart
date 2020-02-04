import 'package:flutter/material.dart';
import 'package:home_manager/Tenant/TenantHomePage.dart';

class TenantPayments extends StatelessWidget {
  final AsyncSnapshot tenantDoc;

  TenantPayments({this.tenantDoc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: MonthlyPaymentsVisibility(
        tenantDoc: tenantDoc,
        didTenantGetHome: true,
      ),
    );
  }
}
