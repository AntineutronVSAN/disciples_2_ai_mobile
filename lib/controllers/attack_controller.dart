import 'package:d2_ai_v2/bloc/bloc.dart';
import 'package:d2_ai_v2/bloc/states.dart';
import 'package:d2_ai_v2/controllers/power_controller.dart';
import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/utils/cell_utils.dart';

import 'damage_scatter.dart';
import 'duration_controller.dart';
import 'game_controller.dart';

class AttackController {
  final PowerController powerController;
  final DamageScatter damageScatter;
  final AttackDurationController attackDurationController;

  Function(Unit unit)? _onUnitAdd2Queue;

  AttackController(
      {required this.powerController,
      required this.damageScatter,
      required this.attackDurationController});

  UpdateStateContext? updateStateContext;
  List<Unit>? units;

  /// Обновить сосстояние UI, если необходимо и если объект предоставлен
  //Future<void> _onUpdate({int duration = 500}) async {
  Future<void> _onUpdate({int duration = 100}) async {

    if (updateStateContext != null && units != null) {
      updateStateContext!
          .emit(updateStateContext!.state.copyWith(units: units));

      switch(updateStateContext!.state.warScreenState) {
        case WarScreenState.eve:
          duration = 200;
          break;
        case WarScreenState.pvp:
          duration = 400;
          break;
        case WarScreenState.pve:
          duration = 400;
          break;
        case WarScreenState.view:
          duration = 400;
          break;
      }

      await Future.delayed(Duration(milliseconds: duration));
    } else {
      //print('Нет контекста для обновления UI');
    }
  }

  Future<ResponseAction> applyAttack(
      int current, int target, List<Unit> units, ResponseAction responseAction,
      {UpdateStateContext? updateStateContext, required Function(Unit unit) onAddUnit2Queue}) async {
    this.updateStateContext = updateStateContext;
    this.units = units;
    _onUnitAdd2Queue = onAddUnit2Queue;

    final _response = await _applyAttack(current, target, units);
    if (!_response.success) {
      return _response;
    }

    await _onUpdate(duration: 1);

    return responseAction.copyWith(success: true);
  }

  // --------------- UNIT PREPROCESSING BEGIN ---------------
  /// Обработать юнита перед его ходом
  Future<bool> unitMovePreprocessing(int index, List<Unit> units,
      {UpdateStateContext? updateStateContext,
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
            //await _onUpdate();
          } else {
            canMove = false;
            units[index].attacksMap[atckId] = units[index]
                .attacksMap[atckId]!
                .copyWith(
                    currentDuration:
                        units[index].attacksMap[atckId]!.currentDuration - 1);
            units[index] = units[index].copyWith(uiInfo: 'Пас');
            //await _onUpdate();
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
          // TODO: Handle this case.
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
      await _onUpdate();
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
  // --------------- UNIT POSTPROCESSING BEGIN ---------------
  /// Обработать юнита после хода
  Future<void> unitMovePostProcessing(int index, List<Unit> units,
      {UpdateStateContext? updateStateContext,
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

      switch (atckValue.attackClass) {
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


            final newDamageCoeff = atckValue.level * 0.25;

            atcksToRemove.add(atckId);
            units[index] = units[index].copyWith(
              damageBusted: false,
              uiInfo: 'Усиление закончено',
              unitAttack: units[index].unitAttack.copyWith(
                  damage: units[index].unitAttack.damage -
                      (units[index].unitAttack.firstDamage * newDamageCoeff).toInt()
              ),
            );
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
            final newDamageCoeff = atckValue.level == 1 ? 0.5 : 0.33;
            atcksToRemove.add(atckId);
            units[index] = units[index].copyWith(
                damageLower: false,
                uiInfo: 'Ослабление закончено',
                unitAttack: units[index].unitAttack.copyWith(
                  damage: units[index].unitAttack.damage +
                      (units[index].unitAttack.firstDamage * newDamageCoeff).toInt(),
              ),
            );
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
            units[index] = units[index].copyWith(
              initLower: false,
              uiInfo: 'Замедление закончено',
              unitAttack: units[index].unitAttack.copyWith(
                initiative: units[index].unitAttack.firstInitiative,
              ),
            );
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

      await _onUpdate();
    }

    for (var atck in atcksToRemove) {
      units[index].attacksMap.remove(atck);
    }

  }
// --------------- UNIT POSTPROCESSING END ---------------

  Future<ResponseAction> _applyAttack(
      int current, int target, List<Unit> units) async {
    assert(units.length == 12);

    var topFrontLineEmpty = true;
    var botFrontLineEmpty = true;

    final cellHasUnit = units.map((e) {
      return !(e.isEmpty() || e.isDead);
    }).toList();

    for (var i = 0; i < cellHasUnit.length; i++) {
      if (i >= 3 && i <= 5) {
        if (cellHasUnit[i]) {
          topFrontLineEmpty = false;
        }
      }
      if (i >= 6 && i <= 8) {
        if (cellHasUnit[i]) {
          botFrontLineEmpty = false;
        }
      }
    }

    final attackContext = _AttackContext(
        current: current,
        target: target,
        units: units,
        topFrontLineEmpty: topFrontLineEmpty,
        botFrontLineEmpty: botFrontLineEmpty,
        cellHasUnit: cellHasUnit,
        isFirstAttack: true);

    return await _handleAttack(attackContext);
  }

  double _getArmorRatio(Unit unit) {
    var armorRatio = 1.0 - unit.armor / 100.0;
    armorRatio /= (unit.isProtected ? 2.0 : 1.0);
    if (armorRatio < 0.1) {
      armorRatio = 0.1;
    }
    return armorRatio;
  }

  Future<ResponseAction> _handleAttack(_AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;

    switch (currentUnitAttack.attackClass) {
      case AttackClass.L_DAMAGE:
        return await _handleDamage(context);
      case AttackClass.L_DRAIN:
        return await _handleDrain(context);
      case AttackClass.L_PARALYZE:
        return await _handleParalyze(context);
      case AttackClass.L_HEAL:
        return await _handleHeal(context);
      case AttackClass.L_FEAR:
        return await _handleFear(context);
      case AttackClass.L_BOOST_DAMAGE:
        return _handleBustDamage(context);
      case AttackClass.L_PETRIFY:
        return _handlePetrify(context);
      case AttackClass.L_LOWER_DAMAGE:
        return _handleLowerDamage(context);
      case AttackClass.L_LOWER_INITIATIVE:
        return _handleLowerIni(context);
      case AttackClass.L_POISON:
        return _handlePoison(context);
      case AttackClass.L_FROSTBITE:
        return _handleFrostbite(context);
      case AttackClass.L_REVIVE:
        return _handleRevive(context);
      case AttackClass.L_DRAIN_OVERFLOW:
        return _handleDrainOverflow(context);
      case AttackClass.L_CURE:
        return _handleCure(context);
      case AttackClass.L_SUMMON:
        // TODO: Handle this case.
        break;
      case AttackClass.L_DRAIN_LEVEL:
        // TODO: Handle this case.
        break;
      case AttackClass.L_GIVE_ATTACK:
        return _handleGiveAttack(context);
      case AttackClass.L_DOPPELGANGER:
        // TODO: Handle this case.
        break;
      case AttackClass.L_TRANSFORM_SELF:
        // TODO: Handle this case.
        break;
      case AttackClass.L_TRANSFORM_OTHER:
        // TODO: Handle this case.
        break;
      case AttackClass.L_BLISTER:
        return await _handleBlister(context);
      case AttackClass.L_BESTOW_WARDS:
        // TODO: Handle this case.
        break;
      case AttackClass.L_SHATTER:
        return _handleShatter(context);
    }

    return ResponseAction.success();
  }

  Future<ResponseAction> _applyAttacksToUnit(
      UnitAttack attack, UnitAttack? attack2, int target, List<Unit> units,
      {int? current, bool handlePower = true}) async {
    if (!handlePower) {
      await _applyAttackToUnit(attack, target, units, current: current);
      if (attack2 != null) {
        await _applyAttackToUnit(attack2, target, units, current: current);
      }
      return ResponseAction.success();
    }

    if (powerController.applyAttack(attack)) {
      final responseAttack1 =
          await _applyAttackToUnit(attack, target, units, current: current);

      if (units[target].isDead) {
        units[target] = units[target].copyWithDead();
        return ResponseAction.success();
      }

      if (attack2 != null) {
        if (powerController.applyAttack(attack2)) {
          final responseAttack2 = await _applyAttackToUnit(
              attack2, target, units,
              current: current);
        } else {
          //print('Атака 2 промах!');
        }
      }
    } else {
      //print('Атака 1 промах!');
      units[target] = units[target].copyWith(uiInfo: 'Промах');
      await _onUpdate();
    }

    return ResponseAction.success();
  }

  Future<ResponseAction> _applyAttackToUnit(
      UnitAttack attack, int target, List<Unit> units,
      {int? current}) async {
    final targetUnit = units[target];

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

        final damage = (damageScatter.getScattedDamage(currentDamage) *
                _getArmorRatio(targetUnit))
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
        await _onUpdate();
        break;

      case AttackClass.L_DRAIN:
        assert(current != null);
        assert(attack.damage > 0);

        final currentUnit = units[current!];

        final currentUnitHp = currentUnit.currentHp;
        final currentUnitMaxHp = currentUnit.maxHp;
        final targetUnitHp = targetUnit.currentHp;

        final currentAttackDamage = attack.damage;

        final damage = (damageScatter.getScattedDamage(currentAttackDamage) *
                _getArmorRatio(targetUnit))
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
        await _onUpdate();
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
          await _onUpdate();
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
        await _onUpdate();
        break;
      case AttackClass.L_FEAR:
        if (!targetUnit.retreat) {
          units[target] = units[target].copyWith(retreat: true);
        }
        await _onUpdate();
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
                  (units[target].unitAttack.firstDamage * newDamageCoeff).toInt(),
            ),
          );
          await _onUpdate();
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
              units[target].copyWith(
                  petrified: true,
                  uiInfo: 'Окаменение'
              );
          await _onUpdate();
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
                      (units[target].unitAttack.firstDamage * newDamageCoeff).toInt()
                ),
          );
          await _onUpdate();
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
            await _onUpdate();
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
              await _onUpdate();
            }
          }*/
        }

        break;

      case AttackClass.L_LOWER_INITIATIVE:
        final attackLevel = attack.level;
        // Судя по БД, уровень только 1
        assert(attackLevel == 1 );

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
          await _onUpdate();
        } else {
            // Обновляем длительность, если у новой атаки она выше
            final oldDebuffDuration =
                units[target].attacksMap[attack.attackClass]!.currentDuration;
            if (currentAttackDuration > oldDebuffDuration) {
              units[target].attacksMap[attack.attackClass] = attack.copyWith(
                currentDuration: currentAttackDuration,
              );
              units[target] = units[target].copyWith(
                  uiInfo: 'Замедление обновлено', initLower: true);
              await _onUpdate();
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
        await _onUpdate();
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
        await _onUpdate();
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
        await _onUpdate();

        break;
      case AttackClass.L_DRAIN_OVERFLOW:

        final currentDamage = attack.damage;
        final targetHp = targetUnit.currentHp;

        final currentUnitHp = units[current!].currentHp;
        final currentUnitMaxHp = units[current].maxHp;

        assert(currentDamage > 0);
        final damage = (damageScatter.getScattedDamage(currentDamage) *
            _getArmorRatio(targetUnit))
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
          currentHp: newTargetHp,
          isDead: isDead,
          uiInfo: ' - $damage'
        );

        // Сначала лафйстилим себя, затем, если что-то осталось раздаём на остальных
        final currentUnitDeltaHp = currentUnitMaxHp - currentUnitHp;
        if (currentUnitDeltaHp >= lifesteel) {
          // Весь лайфстил на себя
          units[current] = units[current].copyWith(
            uiInfo: ' + ${lifesteel.toInt()}',
            currentHp: units[current].currentHp + lifesteel.toInt()
          );
          await _onUpdate();

        } else {
          // Долечиваем себя и раздаём на остальных
          var alliesLifesteel = lifesteel - currentUnitDeltaHp;
          assert(alliesLifesteel > 0);
          if (currentUnitDeltaHp != 0) {
            units[current] = units[current].copyWith(
                uiInfo: ' + $lifesteel',
                currentHp: units[current].currentHp + currentUnitDeltaHp
            );
            await _onUpdate();
          }

          var i1 = checkIsTopTeam(current) ? 0 : 6;
          var i2 = checkIsTopTeam(current) ? 5 : 11;

          int needHeadCount = 0;

          final List<bool> unitNeedHeal = [];

          for (var i=0; i<units.length; i++) {
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

          for(var i=0; i<units.length; i++) {
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
          await _onUpdate();
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
          await _onUpdate();
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
        if (units[target] == units[current!]) {
          break;
        }
        if (_onUnitAdd2Queue != null) {
          _onUnitAdd2Queue!(units[target]);
          units[target] = units[target].copyWith(uiInfo: 'Вторая атака');
          await _onUpdate();
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
        // TODO: Handle this case.
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
        await _onUpdate();
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
        await _onUpdate();

        break;
    }

    return ResponseAction.success();
  }

  // DAMAGE BEGIN
  Future<ResponseAction> _handleDamage(_AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;

    if (context.units[context.target].isDead) {
      return ResponseAction.error('Невозможно атаковать мёртвого');
    }
    if (context.units[context.target].isEmpty()) {
      return ResponseAction.error('Невозможно атаковать пустого');
    }

    switch (currentUnitAttack.targetsCount) {
      case TargetsCount.one:
        return await _handleOneTargetDamage(context);
      case TargetsCount.all:
        return await _handleAllTargetDamage(context);
      case TargetsCount.any:
        return await _handleAnyTargetDamage(context);
    }
  }

  Future<ResponseAction> _handleOneTargetDamage(_AttackContext context) async {
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam == targetUnitIsTopTeam) {
      return ResponseAction.error(
          'Юнит не может актаковать юнита из совей команды');
    }

    final canAttack = findNearestTarget(
        unit: currentUnit,
        index: context.current,
        target: context.target,
        cellHasUnit: context.cellHasUnit,
        direction: currentUnitIsTopTeam,
        topFrontEmpty: context.topFrontLineEmpty,
        botFrontEmpty: context.botFrontLineEmpty,
        currentRecursionLevel: 0);
    if (!canAttack) {
      return ResponseAction.error(
          'Юнит ${currentUnit.unitName} не может атаковать юнита ${targetUnit.unitName}');
    }

    return await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units);
  }

  Future<ResponseAction> _handleAnyTargetDamage(_AttackContext context) async {
    final currentUnit = context.units[context.current];

    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam == targetUnitIsTopTeam) {
      return ResponseAction.error(
          'Юнит не может актаковать юнита из совей команды');
    }

    return await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units);
  }

  Future<ResponseAction> _handleAllTargetDamage(_AttackContext context) async {
    final currentUnit = context.units[context.current];

    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam == targetUnitIsTopTeam) {
      return ResponseAction.error(
          'Юнит не может актаковать юнита из совей команды');
    }
    var i1 = targetUnitIsTopTeam ? 0 : 6;
    var i2 = targetUnitIsTopTeam ? 5 : 11;

    for (var i = 0; i < context.units.length; i++) {
      if (i >= i1 && i <= i2) {
        if (context.units[i].isEmpty() || context.units[i].isDead) {
          continue;
        }
        final resp = await _applyAttacksToUnit(
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units);
      }
    }
    return ResponseAction.success();
  }

// DAMAGE END
// HEAL START
  Future<ResponseAction> _handleHeal(_AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam != targetUnitIsTopTeam) {
      return ResponseAction.error('Хил не может лечить врагов');
    }
    // Хилы могут воскрешать
    if (targetUnit.isDead
        && !(currentUnit.unitAttack2?.attackClass == AttackClass.L_REVIVE)
        && !targetUnit.revived) {
      return ResponseAction.error('Хил не может лечить мёртвого либо юнит уже воскрешался');
    }
    if (targetUnit.isEmpty()) {
      return ResponseAction.error('Хил не может лечить пустого');
    }
    // todo Тут надо подумать, как сделать. Защититься после первой атаки
    // todo невозможно, и ход завершить не удаётся
    /*if (targetUnit.currentHp == targetUnit.maxHp) {
      return ResponseAction.error('Хил не может лечить. Юнит фуловый');
    }*/

    switch (currentUnitAttack.targetsCount) {
      case TargetsCount.one:
        throw Exception();
      case TargetsCount.all:
        return await _handleAllTargetHeal(context);
      case TargetsCount.any:
        return await _handleAnyTargetHeal(context);
    }
  }

  Future<ResponseAction> _handleAllTargetHeal(_AttackContext context) async {
    final currentUnit = context.units[context.current];

    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    var i1 = targetUnitIsTopTeam ? 0 : 6;
    var i2 = targetUnitIsTopTeam ? 5 : 11;

    for (var i = 0; i < context.units.length; i++) {
      if (i >= i1 && i <= i2) {
        if (context.units[i].isEmpty() ||
            (context.units[i].isDead &&
                !(currentUnit.unitAttack2?.attackClass == AttackClass.L_REVIVE)
            )
        ) {
          continue;
        }
        final resp = await _applyAttacksToUnit(
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units,
            handlePower: false);
      }
    }

    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAnyTargetHeal(_AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        handlePower: false);
    return ResponseAction.success();
  }

// HEAL END
// DRAIN BEGIN

  Future<ResponseAction> _handleDrain(_AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam == targetUnitIsTopTeam) {
      return ResponseAction.error('Своих бить вампиризмом нельзя');
    }
    if (targetUnit.isDead || targetUnit.isEmpty()) {
      return ResponseAction.error(
          'Невозможное действие над мёртвым/пустым юнитом');
    }

    switch (currentUnitAttack.targetsCount) {
      case TargetsCount.one:
        return await _handleOneTargetDrain(context);

      case TargetsCount.all:
        return await _handleAllTargetDrain(context);

      case TargetsCount.any:
        return await _handleAnyTargetDrain(context);
    }
  }

  Future<ResponseAction> _handleOneTargetDrain(_AttackContext context) async {
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    final canAttack = findNearestTarget(
        unit: currentUnit,
        index: context.current,
        target: context.target,
        cellHasUnit: context.cellHasUnit,
        direction: currentUnitIsTopTeam,
        topFrontEmpty: context.topFrontLineEmpty,
        botFrontEmpty: context.botFrontLineEmpty,
        currentRecursionLevel: 0);
    if (!canAttack) {
      return ResponseAction.error(
          'Юнит ${currentUnit.unitName} не может атаковать юнита ${targetUnit.unitName}');
    }

    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAnyTargetDrain(_AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAllTargetDrain(_AttackContext context) async {
    final currentUnit = context.units[context.current];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);
    var i1 = targetUnitIsTopTeam ? 0 : 6;
    var i2 = targetUnitIsTopTeam ? 5 : 11;
    for (var i = 0; i < context.units.length; i++) {
      if (i >= i1 && i <= i2) {
        if (context.units[i].isEmpty() || context.units[i].isDead) {
          continue;
        }
        final resp = await _applyAttacksToUnit(
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units,
            current: context.current);
      }
    }
    return ResponseAction.success();
  }

// DRAIN END
// PARALYZE BEGIN

  Future<ResponseAction> _handleParalyze(_AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam == targetUnitIsTopTeam) {
      return ResponseAction.error('Своих парализовать нельзя');
    }
    if (targetUnit.isDead || targetUnit.isEmpty()) {
      return ResponseAction.error(
          'Невозможное действие над мёртвым/пустым юнитом');
    }
    switch (currentUnitAttack.targetsCount) {
      case TargetsCount.one:
        return await _handleOneTargetParalyze(context);

      case TargetsCount.all:
        return await _handleAllTargetParalyze(context);

      case TargetsCount.any:
        return await _handleAnyTargetParalyze(context);
    }
  }

  Future<ResponseAction> _handleOneTargetParalyze(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    final canAttack = findNearestTarget(
        unit: currentUnit,
        index: context.current,
        target: context.target,
        cellHasUnit: context.cellHasUnit,
        direction: currentUnitIsTopTeam,
        topFrontEmpty: context.topFrontLineEmpty,
        botFrontEmpty: context.botFrontLineEmpty,
        currentRecursionLevel: 0);
    if (!canAttack) {
      return ResponseAction.error(
          'Юнит ${currentUnit.unitName} не может парализовать юнита ${targetUnit.unitName}');
    }

    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAllTargetParalyze(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);
    var i1 = targetUnitIsTopTeam ? 0 : 6;
    var i2 = targetUnitIsTopTeam ? 5 : 11;
    for (var i = 0; i < context.units.length; i++) {
      if (i >= i1 && i <= i2) {
        if (context.units[i].isEmpty() || context.units[i].isDead) {
          continue;
        }
        final resp = await _applyAttacksToUnit(
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units,
            current: context.current);
      }
    }
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAnyTargetParalyze(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// PARALYZE END
// FEAR START

  Future<ResponseAction> _handleFear(_AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam == targetUnitIsTopTeam) {
      return ResponseAction.error('Своих пугать нельзя');
    }
    if (targetUnit.isDead || targetUnit.isEmpty()) {
      return ResponseAction.error(
          'Невозможное действие над мёртвым/пустым юнитом');
    }
    switch (currentUnitAttack.targetsCount) {
      case TargetsCount.one:
        return await _handleOneTargetFear(context);

      case TargetsCount.all:
        return await _handleAllTargetFear(context);

      case TargetsCount.any:
        return await _handleAnyTargetFear(context);
    }
  }

  Future<ResponseAction> _handleOneTargetFear(_AttackContext context) async {
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    final canAttack = findNearestTarget(
        unit: currentUnit,
        index: context.current,
        target: context.target,
        cellHasUnit: context.cellHasUnit,
        direction: currentUnitIsTopTeam,
        topFrontEmpty: context.topFrontLineEmpty,
        botFrontEmpty: context.botFrontLineEmpty,
        currentRecursionLevel: 0);
    if (!canAttack) {
      return ResponseAction.error(
          'Юнит ${currentUnit.unitName} не может парализовать юнита ${targetUnit.unitName}');
    }

    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAllTargetFear(_AttackContext context) async {
    final currentUnit = context.units[context.current];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);
    var i1 = targetUnitIsTopTeam ? 0 : 6;
    var i2 = targetUnitIsTopTeam ? 5 : 11;
    for (var i = 0; i < context.units.length; i++) {
      if (i >= i1 && i <= i2) {
        if (context.units[i].isEmpty() || context.units[i].isDead) {
          continue;
        }
        final resp = await _applyAttacksToUnit(
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units,
            current: context.current);
      }
    }
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAnyTargetFear(_AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// FEAR END
// POISON START

  Future<ResponseAction> _handlePoison(_AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam == targetUnitIsTopTeam) {
      return ResponseAction.error('Своих травить нельзя');
    }
    if (targetUnit.isDead || targetUnit.isEmpty()) {
      return ResponseAction.error(
          'Невозможное действие над мёртвым/пустым юнитом');
    }
    switch (currentUnitAttack.targetsCount) {
      case TargetsCount.one:
        return await _handleOneTargetPoison(context);

      case TargetsCount.all:
        return await _handleAllTargetPoison(context);

      case TargetsCount.any:
        return await _handleAnyTargetPoison(context);
    }
  }

  Future<ResponseAction> _handleOneTargetPoison(_AttackContext context) async {
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    final canAttack = findNearestTarget(
        unit: currentUnit,
        index: context.current,
        target: context.target,
        cellHasUnit: context.cellHasUnit,
        direction: currentUnitIsTopTeam,
        topFrontEmpty: context.topFrontLineEmpty,
        botFrontEmpty: context.botFrontLineEmpty,
        currentRecursionLevel: 0);
    if (!canAttack) {
      return ResponseAction.error(
          'Юнит ${currentUnit.unitName} не может парализовать юнита ${targetUnit.unitName}');
    }

    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAllTargetPoison(_AttackContext context) async {
    final currentUnit = context.units[context.current];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);
    var i1 = targetUnitIsTopTeam ? 0 : 6;
    var i2 = targetUnitIsTopTeam ? 5 : 11;
    for (var i = 0; i < context.units.length; i++) {
      if (i >= i1 && i <= i2) {
        if (context.units[i].isEmpty() || context.units[i].isDead) {
          continue;
        }
        final resp = await _applyAttacksToUnit(
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units,
            current: context.current);
      }
    }
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAnyTargetPoison(_AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// POISON END
// BLISTER START

  Future<ResponseAction> _handleBlister(_AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam == targetUnitIsTopTeam) {
      return ResponseAction.error('Своих обжигать нельзя');
    }
    if (targetUnit.isDead || targetUnit.isEmpty()) {
      return ResponseAction.error(
          'Невозможное действие над мёртвым/пустым юнитом');
    }
    switch (currentUnitAttack.targetsCount) {
      case TargetsCount.one:
        return await _handleOneTargetBlister(context);

      case TargetsCount.all:
        return await _handleAllTargetBlister(context);

      case TargetsCount.any:
        return await _handleAnyTargetBlister(context);
    }
  }

  Future<ResponseAction> _handleOneTargetBlister(_AttackContext context) async {
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    final canAttack = findNearestTarget(
        unit: currentUnit,
        index: context.current,
        target: context.target,
        cellHasUnit: context.cellHasUnit,
        direction: currentUnitIsTopTeam,
        topFrontEmpty: context.topFrontLineEmpty,
        botFrontEmpty: context.botFrontLineEmpty,
        currentRecursionLevel: 0);
    if (!canAttack) {
      return ResponseAction.error(
          'Юнит ${currentUnit.unitName} не может обжеч юнита ${targetUnit.unitName}');
    }

    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAllTargetBlister(_AttackContext context) async {
    final currentUnit = context.units[context.current];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);
    var i1 = targetUnitIsTopTeam ? 0 : 6;
    var i2 = targetUnitIsTopTeam ? 5 : 11;
    for (var i = 0; i < context.units.length; i++) {
      if (i >= i1 && i <= i2) {
        if (context.units[i].isEmpty() || context.units[i].isDead) {
          continue;
        }
        final resp = await _applyAttacksToUnit(
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units,
            current: context.current);
      }
    }
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAnyTargetBlister(_AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// BLISTER END
// L_FROSTBITE START

  Future<ResponseAction> _handleFrostbite(_AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam == targetUnitIsTopTeam) {
      return ResponseAction.error('Своих обжигать нельзя');
    }
    if (targetUnit.isDead || targetUnit.isEmpty()) {
      return ResponseAction.error(
          'Невозможное действие над мёртвым/пустым юнитом');
    }
    switch (currentUnitAttack.targetsCount) {
      case TargetsCount.one:
        return await _handleOneTargetFrostbite(context);

      case TargetsCount.all:
        return await _handleAllTargetFrostbite(context);

      case TargetsCount.any:
        return await _handleAnyTargetFrostbite(context);
    }
  }

  Future<ResponseAction> _handleOneTargetFrostbite(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    final canAttack = findNearestTarget(
        unit: currentUnit,
        index: context.current,
        target: context.target,
        cellHasUnit: context.cellHasUnit,
        direction: currentUnitIsTopTeam,
        topFrontEmpty: context.topFrontLineEmpty,
        botFrontEmpty: context.botFrontLineEmpty,
        currentRecursionLevel: 0);
    if (!canAttack) {
      return ResponseAction.error(
          'Юнит ${currentUnit.unitName} не может заморозить юнита ${targetUnit.unitName}');
    }

    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAllTargetFrostbite(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);
    var i1 = targetUnitIsTopTeam ? 0 : 6;
    var i2 = targetUnitIsTopTeam ? 5 : 11;
    for (var i = 0; i < context.units.length; i++) {
      if (i >= i1 && i <= i2) {
        if (context.units[i].isEmpty() || context.units[i].isDead) {
          continue;
        }
        final resp = await _applyAttacksToUnit(
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units,
            current: context.current);
      }
    }
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAnyTargetFrostbite(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// L_FROSTBITE END
// L_CURE START

  Future<ResponseAction> _handleCure(_AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam != targetUnitIsTopTeam) {
      return ResponseAction.error('Чужих лечить нельзя');
    }
    if (targetUnit.isDead || targetUnit.isEmpty()) {
      return ResponseAction.error(
          'Невозможное действие над мёртвым/пустым юнитом');
    }
    switch (currentUnitAttack.targetsCount) {
      case TargetsCount.one:
        throw Exception();

      case TargetsCount.all:
        return await _handleAllTargetCure(context);

      case TargetsCount.any:
        return await _handleAnyTargetCure(context);
    }
  }

  /*Future<ResponseAction> _handleOneTargetCure(_AttackContext context) async {
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    final canAttack = findNearestTarget(
        unit: currentUnit,
        index: context.current,
        target: context.target,
        cellHasUnit: context.cellHasUnit,
        direction: currentUnitIsTopTeam,
        topFrontEmpty: context.topFrontLineEmpty,
        botFrontEmpty: context.botFrontLineEmpty,
        currentRecursionLevel: 0);
    if (!canAttack) {
      return ResponseAction.error(
          'Юнит ${currentUnit.unitName} не может заморозить юнита ${targetUnit.unitName}');
    }

    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }*/

  Future<ResponseAction> _handleAllTargetCure(_AttackContext context) async {
    final currentUnit = context.units[context.current];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);
    var i1 = targetUnitIsTopTeam ? 0 : 6;
    var i2 = targetUnitIsTopTeam ? 5 : 11;
    for (var i = 0; i < context.units.length; i++) {
      if (i >= i1 && i <= i2) {
        if (context.units[i].isEmpty() || context.units[i].isDead) {
          continue;
        }
        final resp = await _applyAttacksToUnit(
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units,
            current: context.current, handlePower: false);
      }
    }
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAnyTargetCure(_AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current, handlePower: false);
    return ResponseAction.success();
  }

// L_CURE END
// L_LOWER_DAMAGE START

  Future<ResponseAction> _handleLowerDamage(_AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam == targetUnitIsTopTeam) {
      return ResponseAction.error('Своим понижать повреждения нельзя');
    }
    if (targetUnit.isDead || targetUnit.isEmpty()) {
      return ResponseAction.error(
          'Невозможное действие над мёртвым/пустым юнитом');
    }
    switch (currentUnitAttack.targetsCount) {
      case TargetsCount.one:
        return await _handleOneTargetLowerDamage(context);

      case TargetsCount.all:
        return await _handleAllTargetLowerDamage(context);

      case TargetsCount.any:
        return await _handleAnyTargetLowerDamage(context);
    }
  }

  Future<ResponseAction> _handleOneTargetLowerDamage(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    final canAttack = findNearestTarget(
        unit: currentUnit,
        index: context.current,
        target: context.target,
        cellHasUnit: context.cellHasUnit,
        direction: currentUnitIsTopTeam,
        topFrontEmpty: context.topFrontLineEmpty,
        botFrontEmpty: context.botFrontLineEmpty,
        currentRecursionLevel: 0);
    if (!canAttack) {
      return ResponseAction.error(
          'Юнит ${currentUnit.unitName} не может заморозить юнита ${targetUnit.unitName}');
    }

    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAllTargetLowerDamage(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);
    var i1 = targetUnitIsTopTeam ? 0 : 6;
    var i2 = targetUnitIsTopTeam ? 5 : 11;
    for (var i = 0; i < context.units.length; i++) {
      if (i >= i1 && i <= i2) {
        if (context.units[i].isEmpty() || context.units[i].isDead) {
          continue;
        }
        final resp = await _applyAttacksToUnit(
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units,
            current: context.current);
      }
    }
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAnyTargetLowerDamage(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// L_LOWER_DAMAGE END
// L_SHATTER START

  Future<ResponseAction> _handleShatter(_AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam == targetUnitIsTopTeam) {
      return ResponseAction.error('Своим разбирвать броню нельзя');
    }
    if (targetUnit.isDead || targetUnit.isEmpty()) {
      return ResponseAction.error(
          'Невозможное действие над мёртвым/пустым юнитом');
    }
    switch (currentUnitAttack.targetsCount) {
      case TargetsCount.one:
        return await _handleOneTargetShatter(context);

      case TargetsCount.all:
        return await _handleAllTargetShatter(context);

      case TargetsCount.any:
        return await _handleAnyTargetShatter(context);
    }
  }

  Future<ResponseAction> _handleOneTargetShatter(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    final canAttack = findNearestTarget(
        unit: currentUnit,
        index: context.current,
        target: context.target,
        cellHasUnit: context.cellHasUnit,
        direction: currentUnitIsTopTeam,
        topFrontEmpty: context.topFrontLineEmpty,
        botFrontEmpty: context.botFrontLineEmpty,
        currentRecursionLevel: 0);
    if (!canAttack) {
      return ResponseAction.error(
          'Юнит ${currentUnit.unitName} не может заморозить юнита ${targetUnit.unitName}');
    }

    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAllTargetShatter(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);
    var i1 = targetUnitIsTopTeam ? 0 : 6;
    var i2 = targetUnitIsTopTeam ? 5 : 11;
    for (var i = 0; i < context.units.length; i++) {
      if (i >= i1 && i <= i2) {
        if (context.units[i].isEmpty() || context.units[i].isDead) {
          continue;
        }
        final resp = await _applyAttacksToUnit(
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units,
            current: context.current);
      }
    }
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAnyTargetShatter(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// L_SHATTER END

// L_REVIVE

  Future<ResponseAction> _handleRevive(_AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam != targetUnitIsTopTeam) {
      return ResponseAction.error('Чужих воскрешать нельзя');
    }
    if (targetUnit.revived) {
      return ResponseAction.error('Юнит уже воскрешался');
    }
    if (targetUnit.isEmpty()) {
      return ResponseAction.error(
          'Невозможное действие над мёртвым юнитом');
    }
    switch (currentUnitAttack.targetsCount) {
      case TargetsCount.one:
        throw Exception();

      case TargetsCount.all:
        return await _handleAllTargetRevive(context);

      case TargetsCount.any:
        return await _handleAnyTargetRevive(context);
    }
  }

  Future<ResponseAction> _handleAllTargetRevive(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);
    var i1 = targetUnitIsTopTeam ? 0 : 6;
    var i2 = targetUnitIsTopTeam ? 5 : 11;
    for (var i = 0; i < context.units.length; i++) {
      if (i >= i1 && i <= i2) {
        if (context.units[i].isEmpty()) {
          continue;
        }
        final resp = await _applyAttacksToUnit(
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units,
            current: context.current, handlePower: false);
      }
    }
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAnyTargetRevive(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current, handlePower: false);
    return ResponseAction.success();
  }

//L_REVIVE END

// L_PETRIFY

  Future<ResponseAction> _handlePetrify(_AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam == targetUnitIsTopTeam) {
      return ResponseAction.error('Своих окаменять нельзя');
    }
    if (targetUnit.isDead || targetUnit.isEmpty()) {
      return ResponseAction.error(
          'Невозможное действие над мёртвым/пустым юнитом');
    }
    switch (currentUnitAttack.targetsCount) {
      case TargetsCount.one:
        return await _handleOneTargetPetrify(context);

      case TargetsCount.all:
        return await _handleAllTargetPetrify(context);

      case TargetsCount.any:
        return await _handleAnyTargetPetrify(context);
    }
  }

  Future<ResponseAction> _handleOneTargetPetrify(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    final canAttack = findNearestTarget(
        unit: currentUnit,
        index: context.current,
        target: context.target,
        cellHasUnit: context.cellHasUnit,
        direction: currentUnitIsTopTeam,
        topFrontEmpty: context.topFrontLineEmpty,
        botFrontEmpty: context.botFrontLineEmpty,
        currentRecursionLevel: 0);
    if (!canAttack) {
      return ResponseAction.error(
          'Юнит ${currentUnit.unitName} не может парализовать юнита ${targetUnit.unitName}');
    }

    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAllTargetPetrify(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);
    var i1 = targetUnitIsTopTeam ? 0 : 6;
    var i2 = targetUnitIsTopTeam ? 5 : 11;
    for (var i = 0; i < context.units.length; i++) {
      if (i >= i1 && i <= i2) {
        if (context.units[i].isEmpty() || context.units[i].isDead) {
          continue;
        }
        final resp = await _applyAttacksToUnit(
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units,
            current: context.current);
      }
    }
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAnyTargetPetrify(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// L_PETRIFY END

// L_LOWER_INITIATIVE

  Future<ResponseAction> _handleLowerIni(_AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam == targetUnitIsTopTeam) {
      return ResponseAction.error('Своим понижать ини нельзя');
    }
    if (targetUnit.isDead || targetUnit.isEmpty()) {
      return ResponseAction.error(
          'Невозможное действие над мёртвым/пустым юнитом');
    }
    switch (currentUnitAttack.targetsCount) {
      case TargetsCount.one:
        return await _handleOneTargetLowerIni(context);

      case TargetsCount.all:
        return await _handleAllTargetLowerIni(context);

      case TargetsCount.any:
        return await _handleAnyTargetLowerIni(context);
    }
  }

  Future<ResponseAction> _handleOneTargetLowerIni(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    final canAttack = findNearestTarget(
        unit: currentUnit,
        index: context.current,
        target: context.target,
        cellHasUnit: context.cellHasUnit,
        direction: currentUnitIsTopTeam,
        topFrontEmpty: context.topFrontLineEmpty,
        botFrontEmpty: context.botFrontLineEmpty,
        currentRecursionLevel: 0);
    if (!canAttack) {
      return ResponseAction.error(
          'Юнит ${currentUnit.unitName} не может заморозить юнита ${targetUnit.unitName}');
    }

    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAllTargetLowerIni(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);
    var i1 = targetUnitIsTopTeam ? 0 : 6;
    var i2 = targetUnitIsTopTeam ? 5 : 11;
    for (var i = 0; i < context.units.length; i++) {
      if (i >= i1 && i <= i2) {
        if (context.units[i].isEmpty() || context.units[i].isDead) {
          continue;
        }
        final resp = await _applyAttacksToUnit(
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units,
            current: context.current);
      }
    }
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAnyTargetLowerIni(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// L_LOWER_INITIATIVE END

// L_GIVE_ATTACK

  Future<ResponseAction> _handleGiveAttack(_AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam != targetUnitIsTopTeam) {
      return ResponseAction.error('Чцжим давать атакоу нельзя');
    }
    if (targetUnit.isDead || targetUnit.isEmpty()) {
      return ResponseAction.error(
          'Невозможное действие над мёртвым/пустым юнитом');
    }
    switch (currentUnitAttack.targetsCount) {
      case TargetsCount.one:
        return await _handleOneTargetGiveAttack(context);

      case TargetsCount.all:
        return await _handleAllTargetGiveAttack(context);

      case TargetsCount.any:
        return await _handleAnyTargetGiveAttack(context);
    }
  }

  Future<ResponseAction> _handleOneTargetGiveAttack(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    final canAttack = findNearestTarget(
        unit: currentUnit,
        index: context.current,
        target: context.target,
        cellHasUnit: context.cellHasUnit,
        direction: currentUnitIsTopTeam,
        topFrontEmpty: context.topFrontLineEmpty,
        botFrontEmpty: context.botFrontLineEmpty,
        currentRecursionLevel: 0);
    if (!canAttack) {
      return ResponseAction.error(
          'Юнит ${currentUnit.unitName} не может заморозить юнита ${targetUnit.unitName}');
    }

    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current, handlePower: false);
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAllTargetGiveAttack(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);
    var i1 = targetUnitIsTopTeam ? 0 : 6;
    var i2 = targetUnitIsTopTeam ? 5 : 11;
    for (var i = 0; i < context.units.length; i++) {
      if (i >= i1 && i <= i2) {
        if (context.units[i].isEmpty() || context.units[i].isDead) {
          continue;
        }
        final resp = await _applyAttacksToUnit(
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units,
            current: context.current, handlePower: false);
      }
    }
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAnyTargetGiveAttack(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current, handlePower: false);
    return ResponseAction.success();
  }

// L_GIVE_ATTACK END

// L_BOOST_DAMAGE

  Future<ResponseAction> _handleBustDamage(_AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam != targetUnitIsTopTeam) {
      return ResponseAction.error('Чужим давать атакоу нельзя');
    }
    if (targetUnit.isDead || targetUnit.isEmpty()) {
      return ResponseAction.error(
          'Невозможное действие над мёртвым/пустым юнитом');
    }
    switch (currentUnitAttack.targetsCount) {
      case TargetsCount.one:
        return await _handleOneTargetBustDamage(context);

      case TargetsCount.all:
        return await _handleAllTargetBustDamage(context);

      case TargetsCount.any:
        return await _handleAnyTargetBustDamage(context);
    }
  }

  Future<ResponseAction> _handleOneTargetBustDamage(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    final canAttack = findNearestTarget(
        unit: currentUnit,
        index: context.current,
        target: context.target,
        cellHasUnit: context.cellHasUnit,
        direction: currentUnitIsTopTeam,
        topFrontEmpty: context.topFrontLineEmpty,
        botFrontEmpty: context.botFrontLineEmpty,
        currentRecursionLevel: 0);
    if (!canAttack) {
      return ResponseAction.error(
          'Юнит ${currentUnit.unitName} не может заморозить юнита ${targetUnit.unitName}');
    }

    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current, handlePower: false);
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAllTargetBustDamage(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);
    var i1 = targetUnitIsTopTeam ? 0 : 6;
    var i2 = targetUnitIsTopTeam ? 5 : 11;
    for (var i = 0; i < context.units.length; i++) {
      if (i >= i1 && i <= i2) {
        if (context.units[i].isEmpty() || context.units[i].isDead) {
          continue;
        }
        final resp = await _applyAttacksToUnit(
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units,
            current: context.current, handlePower: false);
      }
    }
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAnyTargetBustDamage(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current, handlePower: false);
    return ResponseAction.success();
  }

// L_BOOST_DAMAGE END

// L_DRAIN_OVERFLOW

  Future<ResponseAction> _handleDrainOverflow(_AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam == targetUnitIsTopTeam) {
      return ResponseAction.error('Своих бить нельзя');
    }
    if (targetUnit.isDead || targetUnit.isEmpty()) {
      return ResponseAction.error(
          'Невозможное действие над мёртвым/пустым юнитом');
    }
    switch (currentUnitAttack.targetsCount) {
      case TargetsCount.one:
        return await _handleOneTargetDrainOverflow(context);

      case TargetsCount.all:
        return await _handleAllTargetDrainOverflow(context);

      case TargetsCount.any:
        return await _handleAnyTargetDrainOverflow(context);
    }
  }

  Future<ResponseAction> _handleOneTargetDrainOverflow(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    final canAttack = findNearestTarget(
        unit: currentUnit,
        index: context.current,
        target: context.target,
        cellHasUnit: context.cellHasUnit,
        direction: currentUnitIsTopTeam,
        topFrontEmpty: context.topFrontLineEmpty,
        botFrontEmpty: context.botFrontLineEmpty,
        currentRecursionLevel: 0);
    if (!canAttack) {
      return ResponseAction.error(
          'Юнит ${currentUnit.unitName} не может заморозить юнита ${targetUnit.unitName}');
    }

    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAllTargetDrainOverflow(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);
    var i1 = targetUnitIsTopTeam ? 0 : 6;
    var i2 = targetUnitIsTopTeam ? 5 : 11;
    for (var i = 0; i < context.units.length; i++) {
      if (i >= i1 && i <= i2) {
        if (context.units[i].isEmpty() || context.units[i].isDead) {
          continue;
        }
        final resp = await _applyAttacksToUnit(
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units,
            current: context.current);
      }
    }
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAnyTargetDrainOverflow(
      _AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// L_DRAIN_OVERFLOW END

}

class _AttackContext {
  int current;
  int target;
  List<Unit> units;
  bool topFrontLineEmpty;
  bool botFrontLineEmpty;
  List<bool> cellHasUnit;
  bool isFirstAttack;

  _AttackContext({
    required this.current,
    required this.target,
    required this.units,
    required this.topFrontLineEmpty,
    required this.botFrontLineEmpty,
    required this.cellHasUnit,
    this.isFirstAttack = true,
  });

  _AttackContext copyWith({
    current,
    target,
    units,
    topFrontLineEmpty,
    botFrontLineEmpty,
    cellHasUnit,
    isFirstAttack,
  }) {
    return _AttackContext(
      current: current ?? this.current,
      target: target ?? this.target,
      units: units ?? this.units,
      topFrontLineEmpty: topFrontLineEmpty ?? this.topFrontLineEmpty,
      botFrontLineEmpty: botFrontLineEmpty ?? this.botFrontLineEmpty,
      cellHasUnit: cellHasUnit ?? this.cellHasUnit,
      isFirstAttack: isFirstAttack ?? this.isFirstAttack,
    );
  }
}
