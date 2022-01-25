

import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/unit.dart';

class ImunneController {

  /// Можно ли применить атаку юнита [currentAttack] к юниту [target]
  /// 0 - Можно
  /// 1 - Щит
  /// 2 - Иммунитет
  int canApplyAttack({
    required List<Unit> units,
    required int target,
    required UnitAttack currentAttack}) {

    final curAtckClass = currentAttack.attackClass;
    final curAtckSource = currentAttack.source;
    final targetUnit = units[target];
    
    //final hasClassImmune =

    return 0;
  }

}