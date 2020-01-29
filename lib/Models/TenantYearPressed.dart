import 'package:states_rebuilder/states_rebuilder.dart';

class TenantYearPressed extends StatesRebuilder {
  int yearPressed;

  yearTapped(year) {
    yearPressed = year;
    rebuildStates();
  }
}
