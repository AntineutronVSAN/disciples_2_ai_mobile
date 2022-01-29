

import 'package:d2_ai_v2/bloc_base/bloc_state_base.dart';
import 'package:d2_ai_v2/models/unit.dart';

class UnitState extends BaseState<UnitState> {
  final Unit unit;
  UnitState({required this.unit});
}