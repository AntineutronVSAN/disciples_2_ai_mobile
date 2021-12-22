import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/utils/cell_utils.dart';

/*
class HealController {
  void applyHeal(int current, int target, List<Unit> units) {
    final currentUnit = units[current];
    final targetUnit = units[target];

    switch (currentUnit.targetsCount) {
      case TargetsCount.one:
        throw Exception();
      case TargetsCount.all:
        bool targetIsTopTeam = checkIsTopTeam(target);
        bool currentIsTopTeam = checkIsTopTeam(current);

        assert(targetIsTopTeam == currentIsTopTeam);

        var i1 = targetIsTopTeam ? 0 : 6;
        var i2 = targetIsTopTeam ? 5 : 11;

        for (var i = 0; i < units.length; i++) {
          if (i >= i1 && i <= i2) {
            if (units[i].isEmpty() || units[i].isDead) {
              continue;
            }

            int newHp = units[i].currentHp + currentUnit.heal;
            final maxHp = units[i].maxHp;
            if (newHp > maxHp) {
              newHp = maxHp;
            }
            units[i] = units[i].copyWith(currentHp: newHp);

          }
        }

        break;

      case TargetsCount.any:
        int newHp = targetUnit.currentHp + currentUnit.heal;
        final maxHp = targetUnit.maxHp;
        if (newHp > maxHp) {
          newHp = maxHp;
        }

        units[target] = units[target].copyWith(currentHp: newHp);

        break;
    }
  }
}
*/
