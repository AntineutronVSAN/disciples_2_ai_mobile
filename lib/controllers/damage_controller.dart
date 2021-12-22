import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/utils/cell_utils.dart';

/*
class DamageController {
  /// Применить урон к таргету. Все проверки, можно ли бить юнита
  /// должны быть проведены на более высоком уровне, контроллер
  /// не проверяет, а только применяет урон.
  /// Данный контроллер присваивает [isDead] если юнит убит и
  /// [currentHp]. Контроллер учитывает число целей юнита [targetsCount]
  void applyDamage(int current, int target, List<Unit> units) {
    final currentUnit = units[current];
    final targetUnit = units[target];

    assert(currentUnit.isMoving);
    assert(!currentUnit.isDead);
    assert(!currentUnit.isWaiting);
    assert(!currentUnit.isProtected);
    assert(!currentUnit.isEmpty());
    assert(!targetUnit.isEmpty());
    assert(!targetUnit.isDead);

    final currentUnitDamage = currentUnit.damage;
    final currentUnitCritical = currentUnit.criticalHit;

    final targetProtected = targetUnit.isProtected;

    switch (currentUnit.targetsCount) {
      case TargetsCount.one:
        double protectCoeff = targetProtected ? 2.0 : 1.0;
        bool isDead = false;
        var newHp = targetUnit.currentHp -
            (currentUnitDamage / protectCoeff) -
            currentUnitCritical;
        if (newHp < 0.0) {
          isDead = true;
          newHp = 0.0;
        }

        units[target] = units[target].copyWith(currentHp: newHp.toInt(), isDead: isDead);

        break;
      case TargetsCount.all:
        bool targetIsTopTeam = checkIsTopTeam(target);

        var i1 = targetIsTopTeam ? 0 : 6;
        var i2 = targetIsTopTeam ? 5 : 11;

        for (var i = 0; i < units.length; i++) {
          if (i >= i1 && i <= i2) {
            if (units[i].isEmpty() || units[i].isDead) {
              continue;
            }
            var unitProtected = units[i].isProtected;
            double protectCoeff = unitProtected ? 2.0 : 1.0;
            bool isDead = false;
            var newHp = units[i].currentHp -
                (currentUnitDamage / protectCoeff) -
                currentUnitCritical;
            if (newHp < 0.0) {
              isDead = true;
              newHp = 0.0;
            }
            units[i] = units[i].copyWith(currentHp: newHp.toInt(), isDead: isDead);
          }
        }

        break;
      case TargetsCount.any:
        double protectCoeff = targetProtected ? 2.0 : 1.0;
        bool isDead = false;
        var newHp = targetUnit.currentHp -
            (currentUnitDamage / protectCoeff) -
            currentUnitCritical;
        if (newHp < 0.0) {
          isDead = true;
          newHp = 0.0;
        }

        units[target] = units[target].copyWith(currentHp: newHp.toInt(), isDead: isDead);
        break;
    }
  }
}

class WardsController {
  void applyWards(int current, List<Unit> units) {}
}
*/
