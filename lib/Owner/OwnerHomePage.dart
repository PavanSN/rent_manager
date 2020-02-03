import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class Owner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(LineIcons.plus), onPressed: null),
      ),
    );
  }
}
