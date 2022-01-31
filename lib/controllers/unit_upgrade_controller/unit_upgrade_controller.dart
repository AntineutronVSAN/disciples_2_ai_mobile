

import 'package:d2_ai_v2/models/unit.dart';

class UnitUpgradeController {


  bool setLevel(int level, int current, List<Unit> units) {

    final u = units[current];

    if (u.isEmpty()) {
      return false;
    }

    if (level > 99 || level < 0) {
      return false;
    }

    /*if (u.unitConstParams.nextID != null) { // TODO
      print('Юнит не может получить конкретный уровень, '
          'так как это не конец ветки развития');
      return false;
    }*/

    final attack = u.unitAttack;

    final newHp = u.unitConstParams.maxHp + (u.unitConstParams.upgradeHp*level);
    var newArmor = u.armor + (u.unitConstParams.upgradeArmor*level);
    newArmor = newArmor > 90 ? 90 : newArmor;

    var newInitiative = attack.attackConstParams.firstInitiative + (u.unitConstParams.upgradeInitiative*level);
    newInitiative = newInitiative > 90 ? 90 : newInitiative;

    final newHeal = attack.attackConstParams.heal + (u.unitConstParams.upgradeHeal*level);
    var newPower = attack.power + (u.unitConstParams.upgradePower*level);
    newPower = newPower > 100 ? 100 : newPower;

    final newDamage = attack.attackConstParams.firstDamage + (u.unitConstParams.upgradeDamage*level);

    int attack2newDamage = 0;
    if ((u.unitAttack2?.damage ?? 0) > 0) {
      attack2newDamage = u.unitAttack2!.damage + u.unitConstParams.upgradeDamage*level;
    }

    units[current] = units[current].copyWith(

      unitConstParams: units[current].unitConstParams.copyWith(
        maxHp: newHp,
        overLevel: true,
      ),

      level: level,
      //maxHp: newHp,
      currentHp: newHp,
      armor: newArmor,

      //overLevel: true,

      unitAttack: attack.copyWith(
        //firstDamage: newDamage,
        damage: newDamage,

        //firstInitiative: newInitiative,
        initiative: newInitiative,

        power: newPower,
        //heal: newHeal,
        attackConstParams: units[current].unitAttack.attackConstParams.copyWith(
          firstDamage: newDamage,
          firstInitiative: newInitiative,
          heal: newHeal,
        )
      ),
      unitAttack2: u.unitAttack2?.copyWith(
        damage: attack2newDamage,
        //firstDamage: attack2newDamage,
        attackConstParams: u.unitAttack2?.attackConstParams.copyWith(
          firstDamage: attack2newDamage,
        )
      ),
    );

    return true;
  }

  Unit? getNextUnit() {

  }

}