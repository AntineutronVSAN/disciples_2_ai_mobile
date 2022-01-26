

import 'package:d2_ai_v2/models/unit.dart';

class UnitUpgradeController {


  bool setLevel(int level, int current, List<Unit> units) {

    final u = units[current];

    if (level > 99 || level < 0) {
      return false;
    }

    if (u.nextID != null) {
      print('Юнит не может получить конкретный уровень, '
          'так как это не конец ветки развития');
      return false;
    }

    final attack = u.unitAttack;

    final newHp = u.maxHp + (u.upgradeHp*level);
    var newArmor = u.armor + (u.upgradeArmor*level);
    newArmor = newArmor > 90 ? 90 : newArmor;

    var newInitiative = attack.firstInitiative + (u.upgradeInitiative*level);
    newInitiative = newInitiative > 90 ? 90 : newInitiative;

    final newHeal = attack.heal + (u.upgradeHeal*level);
    var newPower = attack.power + (u.upgradePower*level);
    newPower = newPower > 100 ? 100 : newPower;

    final newDamage = attack.firstDamage + (u.upgradeDamage*level);

    int attack2newDamage = 0;
    if ((u.unitAttack2?.damage ?? 0) > 0) {
      attack2newDamage = u.unitAttack2!.damage + u.upgradeDamage*level;
    }

    units[current] = units[current].copyWith(
      level: level,
      maxHp: newHp,
      currentHp: newHp,
      armor: newArmor,

      overLevel: true,

      unitAttack: attack.copyWith(
        firstDamage: newDamage,
        damage: newDamage,

        firstInitiative: newInitiative,
        initiative: newInitiative,

        power: newPower,
        heal: newHeal,
      ),
      unitAttack2: u.unitAttack2?.copyWith(
        damage: attack2newDamage,
        firstDamage: attack2newDamage,
      ),
    );

    return true;
  }

  Unit? getNextUnit() {

  }

}