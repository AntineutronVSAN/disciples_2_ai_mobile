


import 'package:d2_ai_v2/controllers/attack_controller/attack_controller.dart';
import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/unit.dart';



extension ReapplyAttacks on AttackController {

  /// Пересчитать все бафы и дебафы на юните. Используется при превращениях,
  /// понижениях уровней и т.п.
  /// Стоит отметить, что при превращении, юнит [current] должен
  /// иметь максимальные параметры
  void reapplyAttacks({
    required List<Unit> units,
    required int current
  }) {

    // 1 Баф/дебафф снимается
    // 2 Баф/дебафф пересчитывается с новыми параметрами
    // todo баг. Неверно работает обновление урона при превращении
    final currentUnit = units[current];

    final unitsAttacks = currentUnit.attacksMap;

    if (unitsAttacks.isEmpty) {
      return;
    }

    // Проверки для того, что бы убедиться что юнит имеет максимальные параметры
    if (!(currentUnit.unitAttack.damage == currentUnit.unitAttack.attackConstParams.firstDamage)) {
      print('adfadf');
    }
    if (!(currentUnit.unitAttack.initiative == currentUnit.unitAttack.attackConstParams.firstInitiative)) {
      print('adfadf');
    }
    assert(currentUnit.unitAttack.damage == currentUnit.unitAttack.attackConstParams.firstDamage);
    assert(currentUnit.unitAttack.initiative == currentUnit.unitAttack.attackConstParams.firstInitiative, '${currentUnit.unitAttack.initiative} != ${currentUnit.unitAttack.attackConstParams.firstInitiative}');

    for(var i in unitsAttacks.entries) {

      final attack = i.value;

      switch(attack.attackConstParams.attackClass) {

        case AttackClass.L_DAMAGE:
          continue;
        case AttackClass.L_DRAIN:
          continue;
        case AttackClass.L_PARALYZE:
          continue;
        case AttackClass.L_HEAL:
          continue;
        case AttackClass.L_FEAR:
          continue;
        case AttackClass.L_BOOST_DAMAGE:



          // Применение атаки на обновлённого юнита
          final attackLevel = attack.attackConstParams.level;
          assert(attackLevel > 0 && attackLevel <= 4);
          final newDamageCoeff = attackLevel * 0.25;
          final unitMaxDamage = units[current].unitAttack.attackConstParams.firstDamage;
          final currentDamage = units[current].unitAttack.damage;

          // units[current] = units[current].copyWith(
          //   damageBusted: true,
          //   unitAttack: units[current].unitAttack.copyWith(
          //     damage: currentDamage + (unitMaxDamage*newDamageCoeff).toInt()
          //   ),
          // );
          units[current].damageBusted = true;
          units[current].unitAttack.damage = currentDamage + (unitMaxDamage*newDamageCoeff).toInt();

          break;
        case AttackClass.L_PETRIFY:
          continue;
        case AttackClass.L_LOWER_DAMAGE:

          final attackLevel = attack.attackConstParams.level;
          assert(attackLevel == 1 || attackLevel == 2);
          final newDamageCoeff = attackLevel == 1 ? 0.5 : 0.33;
          final unitMaxDamage = units[current].unitAttack.attackConstParams.firstDamage;
          final currentDamage = units[current].unitAttack.damage;

          // units[current] = units[current].copyWith(
          //   damageBusted: true,
          //   unitAttack: units[current].unitAttack.copyWith(
          //       damage: currentDamage - (unitMaxDamage * newDamageCoeff).toInt()
          //   ),
          // );
          units[current].damageBusted = true;
          units[current].unitAttack.damage = currentDamage - (unitMaxDamage * newDamageCoeff).toInt();

          break;
        case AttackClass.L_LOWER_INITIATIVE:

          final attackLevel = attack.attackConstParams.level;
          assert(attackLevel == 1);
          final unitMaxIni = units[current].unitAttack.attackConstParams.firstInitiative;

          // units[current] = units[current].copyWith(
          //   initLower: true,
          //   unitAttack: units[current].unitAttack.copyWith(
          //       initiative: unitMaxIni ~/ 2
          //   ),
          // );
          units[current].initLower = true;
          units[current].unitAttack.initiative = unitMaxIni ~/ 2;

          break;
        case AttackClass.L_POISON:
          continue;
        case AttackClass.L_FROSTBITE:
          continue;
        case AttackClass.L_REVIVE:
          continue;
        case AttackClass.L_DRAIN_OVERFLOW:
          continue;
        case AttackClass.L_CURE:
          continue;
        case AttackClass.L_SUMMON:
          continue;
        case AttackClass.L_DRAIN_LEVEL:
          continue;
        case AttackClass.L_GIVE_ATTACK:
          continue;
        case AttackClass.L_DOPPELGANGER:
          continue;
        case AttackClass.L_TRANSFORM_SELF:
          continue;
        case AttackClass.L_TRANSFORM_OTHER:
          continue;
        case AttackClass.L_BLISTER:
          continue;
        case AttackClass.L_BESTOW_WARDS:
          continue;
        case AttackClass.L_SHATTER:
          continue;
      }

    }

  }

}