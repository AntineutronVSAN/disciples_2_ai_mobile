

import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/unit.dart';

class ImmuneController {

  /// Можно ли применить атаку юнита [currentAttack] к юниту [target]
  /// 0 - Можно
  /// 1 - Щит
  /// 2 - Иммунитет
  int canApplyAttack({
    required List<Unit> units,
    required int target,
    required UnitAttack currentAttack}) {

    final curAtckClass = gameAttackNumberFromClass(currentAttack.attackConstParams.attackClass);
    final curAtckSource = currentAttack.attackConstParams.source;
    final targetUnit = units[target];

    final classImunneCat = targetUnit.classImmune[curAtckClass] ?? ImunneCategory.no;
    final sourceImunneCat = targetUnit.sourceImmune[curAtckSource] ?? ImunneCategory.no;

    switch (classImunneCat) {
      case ImunneCategory.no:
        break;
      case ImunneCategory.once:
        final currentHasImunne = targetUnit.hasClassImunne[curAtckClass];
        assert(currentHasImunne != null, 'Если юнит имеет защиту от класса '
            'атаки, то hasClassImunne юнита должен содержать текущее состояние '
            'защиты');
        if (currentHasImunne!) {
          units[target].hasClassImunne[curAtckClass] = false;
          return 1;
        } else {
          break;
        }

      case ImunneCategory.always:
        return 2;
    }

    switch(sourceImunneCat) {

      case ImunneCategory.no:
        return 0;
      case ImunneCategory.once:
        final currentHasImunne = targetUnit.hasSourceImunne[curAtckSource];
        assert(currentHasImunne != null, 'Если юнит имеет защиту от класса '
            'атаки, то hasClassImunne юнита должен содержать текущее состояние '
            'защиты');
        if (currentHasImunne!) {
          units[target].hasSourceImunne[curAtckSource] = false;
          return 1;
        } else {
          return 0;
        }
      case ImunneCategory.always:
        return 2;
    }


    return 0;
  }

}