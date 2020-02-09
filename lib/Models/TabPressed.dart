import 'package:states_rebuilder/states_rebuilder.dart';

class TabPressed extends StatesRebuilder {
  int yearPressed = DateTime
      .now()
      .year;
  int buildingPressed = 0;
  int tenantInBuildingIndex = 0;

  yearTapped(year) {
    yearPressed = year;
    rebuildStates();
  }

  buildingTapped(index) {
    buildingPressed = index;
    rebuildStates();
  }
}
