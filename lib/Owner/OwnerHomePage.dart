import 'package:flutter/material.dart';
import 'package:getflutter/components/carousel/gf_carousel.dart';
import 'package:home_manager/CommonFiles/LoadingScreen.dart';
import 'package:home_manager/CommonFiles/ProfileUi.dart';
import 'package:line_icons/line_icons.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import '../CommonFiles/CommonWidgetsAndData.dart';
import '../Models/TabPressed.dart';
import '../Models/UserDetails.dart';

class Owner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LineIcons.plus),
          onPressed: null,
        ),
      ),
      body: OwnerBody(),
    );
  }
}

class OwnerBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ProfileUi(),
        Expanded(
          flex: 1,
          child: BuildingsTab(),
        ),
        Expanded(
          flex: 8,
          child: BuildingsData(),
        ),
      ],
    );
  }
}

class BuildingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StateBuilder<TabPressed>(
      builder: (context, _) {
        Injector.get<TabPressed>().getBuildingNames();
        return DefaultTabController(
          length: Injector.get<TabPressed>().getBuildingNames().length,
          child: TabBar(
            onTap: (index) {
              Injector.get<TabPressed>().buildingTapped(index);
            },
            labelStyle: TextStyle(
              fontWeight: FontWeight.w700,
            ),
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.red,
            indicatorColor: Colors.red,
            unselectedLabelColor: Color(0xff5f6368),
            isScrollable: true,
            tabs: getTabs(),
          ),
        );
      },
    );
  }
}

getTabs() {
  List<Widget> tabs = [];
  for (int i = 0; i < Injector.get<TabPressed>().buildingName.length; i++) {
    tabs.add(
      Tab(
        text: Injector.get<TabPressed>().buildingName[i],
      ),
    );
  }
  return tabs;
}

class BuildingsData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GFCarousel(
      initialPage: DateTime.now().month,
      enableInfiniteScroll: false,
      items: <Widget>[
        PaymentOfMonth(
          month: 1,
        ),
        PaymentOfMonth(
          month: 2,
        ),
        PaymentOfMonth(
          month: 3,
        ),
        PaymentOfMonth(
          month: 4,
        ),
        PaymentOfMonth(
          month: 5,
        ),
        PaymentOfMonth(
          month: 6,
        ),
        PaymentOfMonth(
          month: 7,
        ),
        PaymentOfMonth(
          month: 8,
        ),
        PaymentOfMonth(
          month: 9,
        ),
        PaymentOfMonth(
          month: 10,
        ),
        PaymentOfMonth(
          month: 11,
        ),
        PaymentOfMonth(
          month: 12,
        ),
      ],
    );
  }
}

class PaymentOfMonth extends StatelessWidget {
  final int month;
  PaymentOfMonth({this.month});
  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      models: [Injector.get<TabPressed>()],
      child: ListView.builder(
        itemCount: Injector.get<TabPressed>().getBuildingNames().length,
        itemBuilder: (context, index) {
          print(Injector.get<TabPressed>().buildingName[index]);
          return ListTile(
            title: Text(
                Injector.get<TabPressed>(context: context).buildingName[index]),
          );
        },
      ),
    );
  }
}
