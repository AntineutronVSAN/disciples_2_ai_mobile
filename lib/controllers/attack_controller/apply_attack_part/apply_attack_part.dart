

import 'package:d2_ai_v2/controllers/attack_controller/attack_controller.dart';
import 'package:d2_ai_v2/controllers/attack_controller/reapply_attack/reapply_attack_part.dart';
import 'package:d2_ai_v2/controllers/game_controller/actions.dart';
import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/utils/cell_utils.dart';

extension ApplyAttack on AttackController {

  Future<ResponseAction> applyAttackToUnit(
      UnitAttack attack, int target, List<Unit> units,
      {required int current}) async {
    final targetUnit = units[target];

    final rollMaxDamage = checkIsTopTeam(current) && rollConfig!.topTeamMaxDamage ||
        !checkIsTopTeam(current) && rollConfig!.bottomTeamMaxDamage;

    switch (attack.attackClass) {
      case AttackClass.L_DAMAGE:
        final currentDamage = attack.damage;
        final targetHp = targetUnit.currentHp;

        //assert(currentDamage > 0);
        if (currentDamage <= 0) {
          // todo Случается баг, когда увеличение урона наоборот уменьшает его
          print(currentDamage);
          assert(currentDamage > 0);
        }

        final damage = (damageScatter.getScattedDamage(currentDamage, rollMaxDamage: rollMaxDamage) *
            getArmorRatio(targetUnit))
            .toInt();

        var newTargetHp = targetHp - damage;

        var isDead = false;
        if (newTargetHp <= 0) {
          newTargetHp = 0;
          isDead = true;
        }
        units[target] = units[target].copyWith(
          isDead: isDead,
          currentHp: newTargetHp,
          uiInfo: (newTargetHp - targetHp).toString(),
        );
        await onUpdate();
        break;

      case AttackClass.L_DRAIN:
        assert(attack.damage > 0);

        final currentUnit = units[current];

        final currentUnitHp = currentUnit.currentHp;
        final currentUnitMaxHp = currentUnit.maxHp;
        final targetUnitHp = targetUnit.currentHp;

        final currentAttackDamage = attack.damage;

        final damage = (damageScatter.getScattedDamage(currentAttackDamage, rollMaxDamage: rollMaxDamage) *
            getArmorRatio(targetUnit))
            .toInt();
        var lifeSteel = damage ~/ 2;

        var newTargetUnitHp = targetUnitHp - damage;

        bool targetIsDead = false;

        if (newTargetUnitHp <= 0) {
          // Если юнит умер, лайфстил идёт только на оставшуюся часть здоровья
          // цели
          lifeSteel = targetUnitHp ~/ 2;

          //print(lifeSteel);
          //print(damage);
          //assert(lifeSteel < damage ~/ 2);

          newTargetUnitHp = 0;
          targetIsDead = true;
        }

        var newCurrentUnitHp = currentUnitHp + lifeSteel;

        if (newCurrentUnitHp > currentUnitMaxHp) {
          newCurrentUnitHp = currentUnitMaxHp;
        }

        units[current] = units[current].copyWith(
          currentHp: newCurrentUnitHp,
          uiInfo: (newCurrentUnitHp - currentUnitHp).toString(),
        );
        units[target] = units[target].copyWith(
          currentHp: newTargetUnitHp,
          isDead: targetIsDead,
          uiInfo: (newTargetUnitHp - targetUnitHp).toString(),
        );
        await onUpdate();
        break;
      case AttackClass.L_PARALYZE:
        if (targetUnit.petrified) {
          break;
        }

        final targetUnitHasThisAttack =
        targetUnit.attacksMap.containsKey(attack.attackClass);
        final currentAttackDuration =
        attackDurationController.getDuration(attack);

        assert(currentAttackDuration > 0);

        if (!targetUnitHasThisAttack) {
          units[target].attacksMap[attack.attackClass] =
              attack.copyWith(currentDuration: currentAttackDuration);
          units[target] =
              units[target].copyWith(paralyzed: true, uiInfo: 'Паралич');
          await onUpdate();
        } else {
          /*final oldUnitsAttackDuration =
              targetUnit.attacksMap[attack.attackClass]!.currentDuration;
          if (currentAttackDuration > oldUnitsAttackDuration) {
            units[target].attacksMap[attack.attackClass] =
                attack.copyWith(currentDuration: currentAttackDuration);
          }*/
        }

        break;

      case AttackClass.L_HEAL:
        if (targetUnit.isDead) {
          break;
        }

        final currentHealVal = attack.heal;
        assert(currentHealVal > 0);
        final targetHp = targetUnit.currentHp;
        final maxTargetHp = targetUnit.maxHp;
        var newTargetHp = targetHp + currentHealVal;
        if (newTargetHp >= maxTargetHp) {
          newTargetHp = maxTargetHp;
        }

        units[target] = units[target].copyWith(
          currentHp: newTargetHp,
          uiInfo: (newTargetHp - targetHp).toString(),
        );
        await onUpdate();
        break;
      case AttackClass.L_FEAR:
        if (!targetUnit.retreat) {
          units[target] = units[target].copyWith(retreat: true);
          await onUpdate();
        }
        break;
      case AttackClass.L_BOOST_DAMAGE:
        final attackLevel = attack.level;
        assert(attackLevel > 0 && attackLevel <= 4);

        if (units[target].unitAttack.firstDamage <= 0) {
          break;
        }

        final newDamageCoeff = attackLevel * 0.25;
        final newDamageCoeffStr = '${attackLevel * 25}%';

        final targetUnitHasThisAttack =
        targetUnit.attacksMap.containsKey(attack.attackClass);
        final currentAttackDuration = attack.infinite ? 100 : 1;

        if (!targetUnitHasThisAttack) {
          units[target].attacksMap[attack.attackClass] =
              attack.copyWith(currentDuration: currentAttackDuration);
          units[target] = units[target].copyWith(
            uiInfo: 'Усиление на '
                '$newDamageCoeffStr%',
            damageBusted: true,
            unitAttack: units[target].unitAttack.copyWith(
              damage: units[target].unitAttack.damage +
                  (units[target].unitAttack.firstDamage * newDamageCoeff)
                      .toInt(),
            ),
          );
          await onUpdate();
        }
        break;

      case AttackClass.L_PETRIFY:
        if (targetUnit.paralyzed) {
          break;
        }

        final targetUnitHasThisAttack =
        targetUnit.attacksMap.containsKey(attack.attackClass);
        final currentAttackDuration =
        attackDurationController.getDuration(attack);

        assert(currentAttackDuration > 0);

        if (!targetUnitHasThisAttack) {
          units[target].attacksMap[attack.attackClass] =
              attack.copyWith(currentDuration: currentAttackDuration);
          units[target] =
              units[target].copyWith(petrified: true, uiInfo: 'Окаменение');
          await onUpdate();
        }

        break;
      case AttackClass.L_LOWER_DAMAGE:
        final attackLevel = attack.level;
        assert(attackLevel == 1 || attackLevel == 2);

        if (units[target].unitAttack.firstDamage <= 0) {
          break;
        }

        final newDamageCoeff = attackLevel == 1 ? 0.5 : 0.33;
        final newDamageCoeffStr = attackLevel == 1 ? '50' : '33';

        final targetUnitHasThisAttack =
        targetUnit.attacksMap.containsKey(attack.attackClass);
        final currentAttackDuration =
        attackDurationController.getDuration(attack);

        if (!targetUnitHasThisAttack) {
          units[target].attacksMap[attack.attackClass] =
              attack.copyWith(currentDuration: currentAttackDuration);
          units[target] = units[target].copyWith(
            uiInfo: 'Ослабление на '
                '$newDamageCoeffStr%',
            damageLower: true,
            unitAttack: units[target].unitAttack.copyWith(
                damage: units[target].unitAttack.damage -
                    (units[target].unitAttack.firstDamage * newDamageCoeff)
                        .toInt()),
          );
          await onUpdate();
        } else {
          // todo Принимаем, что дебафф не обновляется
          /*final oldDebuffLevel =
              units[target].attacksMap[attack.attackClass]!.level;
          if (oldDebuffLevel > attackLevel) {
            final oldDamageCoeff = oldDebuffLevel == 1 ? 0.5 : 0.33;
            assert(oldDamageCoeff < newDamageCoeff);

            // Новая атака сильнее
            units[target].attacksMap[attack.attackClass] =
                attack.copyWith(currentDuration: currentAttackDuration);
            units[target] = units[target].copyWith(
              uiInfo: 'Ослабление на '
                  '$newDamageCoeffStr%',
              damageLower: true,
              unitAttack: units[target].unitAttack.copyWith(
                damage: units[target].unitAttack.damage -
                    (units[target].unitAttack.damage * ()),
                  ),
            );
            await onUpdate();
          } else if (oldDebuffLevel == attackLevel) {
            // Обновляем длительность, если у новой атаки она выше
            final oldDebuffDuration =
                units[target].attacksMap[attack.attackClass]!.currentDuration;
            if (currentAttackDuration > oldDebuffDuration) {
              units[target].attacksMap[attack.attackClass] = attack.copyWith(
                currentDuration: currentAttackDuration,
              );
              units[target] = units[target].copyWith(
                  uiInfo: 'Ослабление обновлено', damageLower: true);
              await onUpdate();
            }
          }*/
        }

        break;

      case AttackClass.L_LOWER_INITIATIVE:
        final attackLevel = attack.level;
        // Судя по БД, уровень только 1
        assert(attackLevel == 1);

        final targetUnitIniFirst = units[target].unitAttack.firstInitiative;
        if (targetUnitIniFirst <= 0) {
          break;
        }

        final targetUnitHasThisAttack =
        targetUnit.attacksMap.containsKey(attack.attackClass);
        final currentAttackDuration =
        attackDurationController.getDuration(attack);

        if (!targetUnitHasThisAttack) {
          units[target].attacksMap[attack.attackClass] =
              attack.copyWith(currentDuration: currentAttackDuration);
          units[target] = units[target].copyWith(
            uiInfo: 'Змедление на '
                '50%',
            initLower: true,
            unitAttack: units[target].unitAttack.copyWith(
              initiative: (targetUnitIniFirst ~/ 2).toInt(),
            ),
          );
          await onUpdate();
        } else {
          // Обновляем длительность, если у новой атаки она выше
          final oldDebuffDuration =
              units[target].attacksMap[attack.attackClass]!.currentDuration;
          if (currentAttackDuration > oldDebuffDuration) {
            units[target].attacksMap[attack.attackClass] = attack.copyWith(
              currentDuration: currentAttackDuration,
            );
            units[target] = units[target]
                .copyWith(uiInfo: 'Замедление обновлено', initLower: true);
            await onUpdate();
          }
        }

        break;

      case AttackClass.L_POISON:
        final targetUnitHasThisAttack =
        targetUnit.attacksMap.containsKey(attack.attackClass);
        final currentAttackDuration =
        attackDurationController.getDuration(attack);

        assert(currentAttackDuration > 0);

        if (!targetUnitHasThisAttack) {
          units[target].attacksMap[attack.attackClass] =
              attack.copyWith(currentDuration: currentAttackDuration);
        } else {
          // Если дамаг текущего яда больше, применяем новый яд

          final currentAttackDamage =
              units[target].attacksMap[attack.attackClass]!.damage;
          final newAttackDamage = attack.damage;

          if (newAttackDamage > currentAttackDamage) {
            units[target].attacksMap[attack.attackClass] =
                attack.copyWith(currentDuration: currentAttackDuration);
            break;
          }

          // Если дамаг одинаковый, проверяем длительность
          final oldUnitsAttackDuration =
              targetUnit.attacksMap[attack.attackClass]!.currentDuration;
          if (currentAttackDuration > oldUnitsAttackDuration) {
            units[target].attacksMap[attack.attackClass] =
                attack.copyWith(currentDuration: currentAttackDuration);
          }
        }

        units[target] = units[target].copyWith(poisoned: true, uiInfo: 'Яд');
        await onUpdate();
        break;
      case AttackClass.L_FROSTBITE:
        final targetUnitHasThisAttack =
        targetUnit.attacksMap.containsKey(attack.attackClass);
        final currentAttackDuration =
        attackDurationController.getDuration(attack);

        assert(currentAttackDuration > 0);

        if (!targetUnitHasThisAttack) {
          units[target].attacksMap[attack.attackClass] =
              attack.copyWith(currentDuration: currentAttackDuration);
        } else {
          // Если дамаг текущего мороза больше, применяем новый мороза

          final currentAttackDamage =
              units[target].attacksMap[attack.attackClass]!.damage;
          final newAttackDamage = attack.damage;

          if (newAttackDamage > currentAttackDamage) {
            units[target].attacksMap[attack.attackClass] =
                attack.copyWith(currentDuration: currentAttackDuration);
            break;
          }

          // Если дамаг одинаковый, проверяем длительность
          final oldUnitsAttackDuration =
              targetUnit.attacksMap[attack.attackClass]!.currentDuration;
          if (currentAttackDuration > oldUnitsAttackDuration) {
            units[target].attacksMap[attack.attackClass] =
                attack.copyWith(currentDuration: currentAttackDuration);
          }
        }

        units[target] =
            units[target].copyWith(frostbited: true, uiInfo: 'Мороз');
        await onUpdate();
        break;
      case AttackClass.L_REVIVE:
        if (!targetUnit.isDead) {
          break;
        }

        if (targetUnit.revived) {
          break;
        }

        final unitFirstHp = targetUnit.maxHp;
        final newHp = unitFirstHp ~/ 2;

        units[target] = units[target].copyWith(
          isDead: false,
          currentHp: newHp,
          revived: true,
          uiInfo: 'Воскрешение',
          unitAttack: units[target].unitAttack.copyWith(
            damage: units[target].unitAttack.firstDamage,
            initiative: units[target].unitAttack.firstInitiative,
          ),
        );
        await onUpdate();

        break;
      case AttackClass.L_DRAIN_OVERFLOW:
        final currentDamage = attack.damage;
        final targetHp = targetUnit.currentHp;

        final currentUnitHp = units[current].currentHp;
        final currentUnitMaxHp = units[current].maxHp;

        assert(currentDamage > 0);
        final damage = (damageScatter.getScattedDamage(currentDamage, rollMaxDamage: rollMaxDamage) *
            getArmorRatio(targetUnit))
            .toInt();

        var newTargetHp = targetHp - damage;

        double lifesteel = damage / 2.0;

        var isDead = false;
        if (newTargetHp <= 0) {
          newTargetHp = 0;
          isDead = true;
          lifesteel = targetHp / 2.0;
        }

        units[target] = units[target].copyWith(
            currentHp: newTargetHp, isDead: isDead, uiInfo: ' - $damage');

        // Сначала лафйстилим себя, затем, если что-то осталось раздаём на остальных
        final currentUnitDeltaHp = currentUnitMaxHp - currentUnitHp;
        if (currentUnitDeltaHp >= lifesteel) {
          // Весь лайфстил на себя
          units[current] = units[current].copyWith(
              uiInfo: ' + ${lifesteel.toInt()}',
              currentHp: units[current].currentHp + lifesteel.toInt());
          await onUpdate();
        } else {
          // Долечиваем себя и раздаём на остальных
          var alliesLifesteel = lifesteel - currentUnitDeltaHp;
          assert(alliesLifesteel > 0);
          if (currentUnitDeltaHp != 0) {
            units[current] = units[current].copyWith(
                uiInfo: ' + $lifesteel',
                currentHp: units[current].currentHp + currentUnitDeltaHp);
            await onUpdate();
          }

          var i1 = checkIsTopTeam(current) ? 0 : 6;
          var i2 = checkIsTopTeam(current) ? 5 : 11;

          int needHeadCount = 0;

          final List<bool> unitNeedHeal = [];

          for (var i = 0; i < units.length; i++) {
            final e = units[i];
            if (i == current) {
              unitNeedHeal.add(false);
              continue;
            }
            if (!(i >= i1 && i <= i2)) {
              unitNeedHeal.add(false);
              continue;
            }
            if (e.isDead || e.isEmpty()) {
              unitNeedHeal.add(false);
              continue;
            }
            if (e.currentHp >= e.maxHp) {
              unitNeedHeal.add(false);
              continue;
            }
            unitNeedHeal.add(true);
            needHeadCount += 1;
          }
          if (needHeadCount == 0) {
            break;
          }
          var oneUnitHealValue = alliesLifesteel ~/ needHeadCount;

          if (oneUnitHealValue <= 0) {
            break;
          }

          for (var i = 0; i < units.length; i++) {
            if (unitNeedHeal[i]) {
              final currentAllieUnitHp = units[i].currentHp;
              final currentAllieUnitMaxHp = units[i].maxHp;

              var newHp = currentAllieUnitHp + oneUnitHealValue;
              if (newHp > currentAllieUnitMaxHp) {
                // Из лайфстила отнимается только остаток
                alliesLifesteel -= (newHp - currentAllieUnitMaxHp);

                newHp = currentAllieUnitMaxHp;
                unitNeedHeal[i] = false;
                needHeadCount -= 1;
                // Оставшийся лайфстил пересчитывается
                if (needHeadCount < 1) {
                  break;
                }
                oneUnitHealValue = alliesLifesteel ~/ needHeadCount;
              } else {
                alliesLifesteel -= oneUnitHealValue;
              }
              assert(!(alliesLifesteel < 0), '$alliesLifesteel');

              units[i] = units[i].copyWith(
                currentHp: newHp,
                uiInfo: '+ $oneUnitHealValue',
              );
            }
          }
          await onUpdate();
        }

        break;
      case AttackClass.L_CURE:
        if (targetUnit.attacksMap.isEmpty) {
          break;
        }

        // Снимаем все отрицательные эффекты
        final List<AttackClass> toRemove = [];
        for (var targetsAtck in targetUnit.attacksMap.entries) {
          final atckType = targetsAtck.key;
          final atck = targetsAtck.value;

          if (atckType == AttackClass.L_PARALYZE) {
            toRemove.add(atckType);
          }
          if (atckType == AttackClass.L_PETRIFY) {
            toRemove.add(atckType);
          }

          // todo transformed

          if (atck.damage > 0) {
            toRemove.add(atckType);
          }

        }

        for (var atck in toRemove) {
          units[target].attacksMap.remove(atck);
        }

        if (toRemove.isNotEmpty) {
          units[target] = units[target].copyWith(
              frostbited: false,
              blistered: false,
              paralyzed: false,
              poisoned: false,
              petrified: false,
              uiInfo: "Лечение");
          await onUpdate();
        }

        break;
      case AttackClass.L_SUMMON:
      // TODO: Handle this case.
        break;
      case AttackClass.L_DRAIN_LEVEL:
      // TODO: Handle this case.
        break;
      case AttackClass.L_GIVE_ATTACK:
        if (units[target].isDead || units[target].isEmpty()) {
          break;
        }
        assert(current != null);
        if (units[target] == units[current]) {
          break;
        }
        if (onUnitAdd2Queue != null) {
          onUnitAdd2Queue!(units[target]);
          units[target] = units[target].copyWith(uiInfo: 'Вторая атака');
          await onUpdate();
        } else {
          throw Exception();
        }

        break;
      case AttackClass.L_DOPPELGANGER:
      // TODO: Handle this case.
        break;
      case AttackClass.L_TRANSFORM_SELF:
      // TODO: Handle this case.
        break;
      case AttackClass.L_TRANSFORM_OTHER:
        final targetUnitHasThisAttck =
        targetUnit.attacksMap.containsKey(attack.attackClass);

        if (!targetUnitHasThisAttck) {
          final currentAttackDuration =
          attackDurationController.getDuration(attack);
          // В кого превращает юнит
          var transformedUnit =
          gameRepository.getTransformUnitByAttackId(attack.attackId);
          // Нужно запомнить текущее состояние юнита
          assert(transformedUnitsCache[targetUnit.unitWarId] == null);
          transformedUnitsCache[targetUnit.unitWarId] = targetUnit.copyWith();

          units[target].attacksMap[attack.attackClass] =
              attack.copyWith(currentDuration: currentAttackDuration);

          units[target] = units[target].copyWith(
            unitName: transformedUnit.unitName,
            // todo Резисты переносятся также с юнита в кого превращаемся
            armor: transformedUnit.armor,
            unitAttack: transformedUnit.unitAttack,
            unitAttack2: transformedUnit.unitAttack2,
            // todo баг если атака null,
            // а у превращаемого юнита не null
            uiInfo: 'Превращение',
            transformed: true,
          );
          await onUpdate();
          reapplyAttacks(units: units, current: target);
          //units[target] = units[target].copyWith(uiInfo: 'Баф/дебафы пересчитаны');
          await onUpdate();
        }

        break;
      case AttackClass.L_BLISTER:
        final targetUnitHasThisAttack =
        targetUnit.attacksMap.containsKey(attack.attackClass);
        final currentAttackDuration =
        attackDurationController.getDuration(attack);

        assert(currentAttackDuration > 0);

        if (!targetUnitHasThisAttack) {
          units[target].attacksMap[attack.attackClass] =
              attack.copyWith(currentDuration: currentAttackDuration);
        } else {
          // Если дамаг текущего ожёга больше, применяем новый ожёга

          final currentAttackDamage =
              units[target].attacksMap[attack.attackClass]!.damage;
          final newAttackDamage = attack.damage;

          if (newAttackDamage > currentAttackDamage) {
            units[target].attacksMap[attack.attackClass] =
                attack.copyWith(currentDuration: currentAttackDuration);
            break;
          }

          // Если дамаг одинаковый, проверяем длительность
          final oldUnitsAttackDuration =
              targetUnit.attacksMap[attack.attackClass]!.currentDuration;
          if (currentAttackDuration > oldUnitsAttackDuration) {
            units[target].attacksMap[attack.attackClass] =
                attack.copyWith(currentDuration: currentAttackDuration);
          }
        }

        units[target] = units[target].copyWith(blistered: true, uiInfo: 'Ожёг');
        await onUpdate();
        break;
      case AttackClass.L_BESTOW_WARDS:
      // TODO: Handle this case.
        break;
      case AttackClass.L_SHATTER:
      // todo Есть броня, которая не разбивается
        final targetUnitArmor = targetUnit.armor;
        if (targetUnitArmor <= 0) {
          break;
        }

        final currentAttackShakeValue = attack.damage;
        assert(currentAttackShakeValue > 0);

        var newUnitArmor = targetUnitArmor - currentAttackShakeValue;
        if (newUnitArmor < 0) {
          newUnitArmor = 0;
        }

        units[target] = units[target].copyWith(
          uiInfo: 'Разрушение',
          armor: newUnitArmor,
        );
        await onUpdate();

        break;
    }

    return ResponseAction.success();
  }


}