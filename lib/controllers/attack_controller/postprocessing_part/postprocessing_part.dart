

import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/update_state_context/update_state_context_base.dart';

import '../attack_controller.dart';

extension Postprocessing on AttackController {
  // --------------- UNIT POSTPROCESSING BEGIN ---------------
  /// Обработать юнита после хода
  Future<void> unitMovePostProcessing(
      int index,
      List<Unit> units, {
        UpdateStateContextBase? updateStateContext,
        required bool waiting,
        required bool protecting,
        required bool retriting,
      }) async {
    final List<AttackClass> atcksToRemove = [];

    if (units[index].isDead) {
      return;
    }

    this.updateStateContext = updateStateContext;
    this.units = units;

    for (var atck in units[index].attacksMap.entries) {
      final atckId = atck.key;
      final atckValue = atck.value;

      switch (atckValue.attackConstParams.attackClass) {
        case AttackClass.L_DAMAGE:
          break;
        case AttackClass.L_DRAIN:
          break;
        case AttackClass.L_PARALYZE:
          break;
        case AttackClass.L_HEAL:
          break;
        case AttackClass.L_FEAR:
          break;
        case AttackClass.L_BOOST_DAMAGE:
          if (waiting || protecting) {
            break;
          }
          if (atckValue.currentDuration == 1) {
            final newDamageCoeff = atckValue.attackConstParams.level * 0.25;

            atcksToRemove.add(atckId);
            // units[index] = units[index].copyWith(
            //   damageBusted: false,
            //   uiInfo: 'Усиление закончено',
            //   unitAttack: units[index].unitAttack.copyWith(
            //       damage: units[index].unitAttack.damage -
            //           (units[index].unitAttack.attackConstParams.firstDamage * newDamageCoeff)
            //               .toInt()),
            // );
            units[index].damageBusted = false;
            units[index].uiInfo = 'Усиление закончено';
            units[index].unitAttack.damage -= (units[index].unitAttack.attackConstParams.firstDamage * newDamageCoeff)
                .toInt();

          } else {
            units[index].attacksMap[atckId] = units[index]
                .attacksMap[atckId]!
                .copyWith(
                currentDuration:
                units[index].attacksMap[atckId]!.currentDuration - 1);
          }

          break;
        case AttackClass.L_PETRIFY:
          break;
        case AttackClass.L_LOWER_DAMAGE:
          if (waiting || protecting) {
            break;
          }
          if (atckValue.currentDuration == 1) {
            final newDamageCoeff = atckValue.attackConstParams.level == 1 ? 0.5 : 0.33;
            atcksToRemove.add(atckId);

            // units[index] = units[index].copyWith(
            //   damageLower: false,
            //   uiInfo: 'Ослабление закончено',
            //   unitAttack: units[index].unitAttack.copyWith(
            //     damage: units[index].unitAttack.damage +
            //         (units[index].unitAttack.attackConstParams.firstDamage * newDamageCoeff)
            //             .toInt(),
            //   ),
            // );
            units[index].damageLower = false;
            units[index].uiInfo = 'Ослабление закончено';
            units[index].unitAttack.damage += (units[index].unitAttack.attackConstParams.firstDamage * newDamageCoeff)
                .toInt();

          } else {
            units[index].attacksMap[atckId] = units[index]
                .attacksMap[atckId]!
                .copyWith(
                currentDuration:
                units[index].attacksMap[atckId]!.currentDuration - 1);
          }

          break;
        case AttackClass.L_LOWER_INITIATIVE:
          if (atckValue.currentDuration == 1) {
            atcksToRemove.add(atckId);

            // units[index] = units[index].copyWith(
            //   initLower: false,
            //   uiInfo: 'Замедление закончено',
            //   unitAttack: units[index].unitAttack.copyWith(
            //     initiative: units[index].unitAttack.attackConstParams.firstInitiative,
            //   ),
            // );
            units[index].initLower = false;
            units[index].uiInfo = 'Замедление закончено';
            units[index].unitAttack.initiative = units[index].unitAttack.attackConstParams.firstInitiative;

          } else {
            units[index].attacksMap[atckId] = units[index]
                .attacksMap[atckId]!
                .copyWith(
                currentDuration:
                units[index].attacksMap[atckId]!.currentDuration - 1);
          }
          break;
        case AttackClass.L_POISON:
          break;
        case AttackClass.L_FROSTBITE:
          break;
        case AttackClass.L_REVIVE:
          break;
        case AttackClass.L_DRAIN_OVERFLOW:
          break;
        case AttackClass.L_CURE:
          break;
        case AttackClass.L_SUMMON:
        // TODO: Handle this case.
          break;
        case AttackClass.L_DRAIN_LEVEL:
          break;
        case AttackClass.L_GIVE_ATTACK:
        // TODO: Handle this case.
          break;
        case AttackClass.L_DOPPELGANGER:
        // TODO: Handle this case.
          break;
        case AttackClass.L_TRANSFORM_SELF:
          break;
        case AttackClass.L_TRANSFORM_OTHER:
          break;
        case AttackClass.L_BLISTER:
          break;
        case AttackClass.L_BESTOW_WARDS:
          break;
        case AttackClass.L_SHATTER:
          break;
      }

      await onUpdate();
    }

    for (var atck in atcksToRemove) {
      units[index].attacksMap.remove(atck);
    }
  }
  // --------------- UNIT POSTPROCESSING END ---------------
}