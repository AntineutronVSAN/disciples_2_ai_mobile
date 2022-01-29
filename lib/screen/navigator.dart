

import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/screen/unit/unit_inforamtion/unit_information_bloc.dart';
import 'package:d2_ai_v2/screen/unit/unit_inforamtion/unit_information_event.dart';
import 'package:d2_ai_v2/screen/unit/unit_inforamtion/unit_information_screen.dart';
import 'package:flutter/cupertino.dart';

class ScreensNavigator {


  static Widget getUnitInfoScreen({required Unit unit}) {

    final bloc = UnitInformationBloc(unit: unit);

    bloc.add(UnitInformationInitialEvent());

    return UnitInformationScreen(bloc: bloc);
  }


}