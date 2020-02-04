import 'package:states_rebuilder/states_rebuilder.dart';

class TabPressed extends StatesRebuilder {
  int yearPressed;
  int buildingPressed = 0;

  yearTapped(year) {
    yearPressed = year;
    rebuildStates();
  }

  buildingTapped(index){
    buildingPressed = index;
    rebuildStates();
  }

}
