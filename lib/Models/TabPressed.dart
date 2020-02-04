import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'UserDetails.dart';

class TabPressed extends StatesRebuilder {
  int yearPressed;
  int building = 0;
  List buildingName = [];

  yearTapped(year) {
    yearPressed = year;
    rebuildStates();
  }

  buildingTapped(index){
    building = index;
    rebuildStates();
  }

  getBuildingNames(){
    Firestore.instance.document('users/${Injector.get<UserDetails>().uid}').get().then((doc){
      buildingName = doc.data['buildings'];
      return buildingName;
    });
    rebuildStates();
  }
}
