import 'package:states_rebuilder/states_rebuilder.dart';

class TabPressed extends StatesRebuilder {
  int yearPressed;
  int building;

  yearTapped(year) {
    yearPressed = year;
    rebuildStates();
  }

  buildingTapped(index){
    building = index;
  }
}
