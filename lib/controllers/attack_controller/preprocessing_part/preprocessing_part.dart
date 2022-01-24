import 'package:d2_ai_v2/controllers/attack_controller/attack_controller.dart';
import 'package:d2_ai_v2/controllers/attack_controller/reapply_attack/reapply_attack_part.dart';
import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/update_state_context/update_state_context_base.dart';

extension Preprocessing on AttackController {

  // --------------- UNIT PREPROCESSING BEGIN ---------------
  /// Обработать юнита перед его ходом
  Future<bool> unitMovePreprocessing(
      int index,
      List<Unit> units, {
        UpdateStateContextBase? updateStateContext,
        required bool waiting,
        required bool protecting,
        required bool retriting,
      }) async {
    final List<AttackClass> atcksToRemove = [];

    if (units[index].isDead) {
      return false;
    }

    this.updateStateContext = updateStateContext;
    this.units = units;

    var canMove = true;

    for (var atck in units[index].attacksMap.entries) {
      final atckId = atck.key;
      final atckValue = atck.value;

      switch (atckValue.attackClass) {
        case AttackClass.L_DAMAGE:
          throw Exception();
        case AttackClass.L_DRAIN:
          throw Exception();
        case AttackClass.L_PARALYZE:
          assert(!units[index].petrified);
          assert(atckValue.currentDuration > 0);
          assert(units[index].attacksMap[atckId] != null);
          // Если перед ходом, длительность паралича = 1, паралич снимается,
          // но текущий ход юнит пропускает
          if (atckValue.currentDuration == 1) {
            canMove = false;
            atcksToRemove.add(atckId);
            units[index] = units[index]
                .copyWith(paralyzed: false, uiInfo: 'Паралич прошёл');
            await onUpdate();
          } else {
            canMove = false;
            units[index].attacksMap[atckId] = units[index]
                .attacksMap[atckId]!
                .copyWith(
                currentDuration:
                units[index].attacksMap[atckId]!.currentDuration - 1);
            units[index] = units[index].copyWith(uiInfo: 'Пас');
            await onUpdate();
          }

          break;
        case AttackClass.L_HEAL:
          throw Exception();
        case AttackClass.L_FEAR:
          throw Exception();
        case AttackClass.L_BOOST_DAMAGE:
        // TODO: Handle this case.
          break;
        case AttackClass.L_PETRIFY:
          assert(!units[index].paralyzed);
          assert(atckValue.currentDuration > 0);
          assert(units[index].attacksMap[atckId] != null);
          // Если перед ходом, длительность паралича = 1, паралич снимается,
          // но текущий ход юнит пропускает
          if (atckValue.currentDuration == 1) {
            canMove = false;
            atcksToRemove.add(atckId);
            units[index] = units[index]
                .copyWith(petrified: false, uiInfo: 'Окаменение прошло');
            await onUpdate();
          } else {
            canMove = false;
            units[index].attacksMap[atckId] = units[index]
                .attacksMap[atckId]!
                .copyWith(
                currentDuration:
                units[index].attacksMap[atckId]!.currentDuration - 1);
            units[index] = units[index].copyWith(uiInfo: 'Статуя');
          }
          break;
        case AttackClass.L_LOWER_DAMAGE:
        // TODO: Handle this case.
          break;
        case AttackClass.L_LOWER_INITIATIVE:
        // TODO: Handle this case.
          break;
        case AttackClass.L_POISON:
          if (units[index].isWaiting) {
            break;
          }
          final poisonDamage = units[index].attacksMap[atckId]!.damage;
          final currentUnitHp = units[index].currentHp;

          var newUnitHp = currentUnitHp - poisonDamage;
          bool isDead = false;

          if (newUnitHp <= 0) {
            newUnitHp = 0;
            isDead = true;
          }

          units[index] = units[index].copyWith(
            isDead: isDead,
            currentHp: newUnitHp,
            uiInfo: newUnitHp - currentUnitHp,
          );
          await onUpdate();
          if (atckValue.currentDuration == 1) {
            atcksToRemove.add(atckId);
            units[index] = units[index]
                .copyWith(poisoned: false, uiInfo: newUnitHp - currentUnitHp);
          } else {
            units[index].attacksMap[atckId] = units[index]
                .attacksMap[atckId]!
                .copyWith(
                currentDuration:
                units[index].attacksMap[atckId]!.currentDuration - 1);
          }
          break;
        case AttackClass.L_FROSTBITE:
          if (units[index].isWaiting) {
            break;
          }
          final frostbiteDamage = units[index].attacksMap[atckId]!.damage;
          final currentUnitHp = units[index].currentHp;

          var newUnitHp = currentUnitHp - frostbiteDamage;
          bool isDead = false;

          if (newUnitHp <= 0) {
            newUnitHp = 0;
            isDead = true;
          }

          units[index] = units[index].copyWith(
            isDead: isDead,
            currentHp: newUnitHp,
            uiInfo: newUnitHp - currentUnitHp,
          );
          await onUpdate();
          if (atckValue.currentDuration == 1) {
            atcksToRemove.add(atckId);
            units[index] = units[index]
                .copyWith(frostbited: false, uiInfo: newUnitHp - currentUnitHp);
          } else {
            units[index].attacksMap[atckId] = units[index]
                .attacksMap[atckId]!
                .copyWith(
                currentDuration:
                units[index].attacksMap[atckId]!.currentDuration - 1);
          }
          break;
        case AttackClass.L_REVIVE:
          throw Exception();
        case AttackClass.L_DRAIN_OVERFLOW:
          throw Exception();
        case AttackClass.L_CURE:
          throw Exception();
        case AttackClass.L_SUMMON:
          throw Exception();
        case AttackClass.L_DRAIN_LEVEL:
          throw Exception();
        case AttackClass.L_GIVE_ATTACK:
        // TODO: Handle this case.
          break;
        case AttackClass.L_DOPPELGANGER:
          throw Exception();
        case AttackClass.L_TRANSFORM_SELF:
        // TODO: Handle this case.
          break;
        case AttackClass.L_TRANSFORM_OTHER:
        /*
          units[target] = units[target].copyWith(
            unitName: transformedUnit.unitName,
            armor: transformedUnit.armor,
            unitAttack: transformedUnit.unitAttack,
            unitAttack2: transformedUnit.unitAttack2,
            uiInfo: 'Превращение',
            transformed: true,
          );
          */
          if (units[index].isWaiting) {
            break;
          }
          if (atckValue.currentDuration < 0) {
            throw Exception();
          }
          if (atckValue.currentDuration == 1) {
            atcksToRemove.add(atckId);
            final unitId = units[index].unitWarId;
            final oldUnit = transformedUnitsCache[unitId]!;

            transformedUnitsCache.remove(unitId);

            units[index] = units[index].copyWith(
              unitName: oldUnit.unitName,
              armor: oldUnit.armor,
              unitAttack: oldUnit.unitAttack,
              unitAttack2: oldUnit.unitAttack2,
              uiInfo: 'Восстановление формы',
              transformed: false,
            );

            // Перед переприменением атак, бафы/дебафы сбрасываются
            units[index] = units[index].copyWith(
              unitAttack: units[index].unitAttack.copyWith(
                initiative: units[index].unitAttack.firstInitiative,
                damage: units[index].unitAttack.firstDamage,
              )
            );
            await onUpdate();
            reapplyAttacks(units: units, current: index);
            //units[index] = units[index].copyWith(uiInfo: 'Бафы/дебафы пересчитаны',);
            await onUpdate();
            break;
          } else {
            units[index].attacksMap[atckId] = units[index]
                .attacksMap[atckId]!
                .copyWith(
                currentDuration:
                units[index].attacksMap[atckId]!.currentDuration - 1);
          }
          // У ждущего юнита первращение не сбрасывается
          /*if (units[index].isWaiting) {
            break;
          }
          if (atckValue.currentDuration < 0) {
            throw Exception();
          }
          if (atckValue.currentDuration == 1) {

            atcksToRemove.add(atckId);

            final unitId = units[index].unitWarId;

            // Возвращается прежний юнит
            units[index] = _transformedUnitsCache[unitId]!.copyWith(
              transformed: false,
              attacksMap: Map.fromIterables(
                  units[index].attacksMap.keys,
                  units[index].attacksMap.values),
              uiInfo: 'Восстановить обличие',
            );

            _transformedUnitsCache.remove(unitId);

          } else {
            units[index].attacksMap[atckId] = units[index]
                .attacksMap[atckId]!
                .copyWith(
                currentDuration:
                units[index].attacksMap[atckId]!.currentDuration - 1);
          }*/

          break;
        case AttackClass.L_BLISTER:
          if (units[index].isWaiting) {
            break;
          }
          final blisterDamage = units[index].attacksMap[atckId]!.damage;
          final currentUnitHp = units[index].currentHp;

          var newUnitHp = currentUnitHp - blisterDamage;
          bool isDead = false;

          if (newUnitHp <= 0) {
            newUnitHp = 0;
            isDead = true;
          }

          units[index] = units[index].copyWith(
            isDead: isDead,
            currentHp: newUnitHp,
            uiInfo: newUnitHp - currentUnitHp,
          );
          await onUpdate();
          if (atckValue.currentDuration == 1) {
            atcksToRemove.add(atckId);
            units[index] = units[index]
                .copyWith(blistered: false, uiInfo: newUnitHp - currentUnitHp);
          } else {
            units[index].attacksMap[atckId] = units[index]
                .attacksMap[atckId]!
                .copyWith(
                currentDuration:
                units[index].attacksMap[atckId]!.currentDuration - 1);
          }
          break;
        case AttackClass.L_BESTOW_WARDS:
        // TODO: Handle this case.
          break;
        case AttackClass.L_SHATTER:
        // TODO: Handle this case.
          break;
      }
      //await onUpdate();
    }

    for (var atck in atcksToRemove) {
      units[index].attacksMap.remove(atck);
    }

    if (units[index].isDead) {
      units[index] = units[index].copyWithDead();
    }

    return canMove;
  }

// --------------- UNIT PREPROCESSING END ---------------

}