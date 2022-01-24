import 'package:d2_ai_v2/bloc/states.dart';
import 'package:d2_ai_v2/controllers/attack_controller/apply_attack_part/apply_attack_part.dart';
import 'package:d2_ai_v2/controllers/game_controller/actions.dart';
import 'package:d2_ai_v2/controllers/game_controller/roll_config.dart';
import 'package:d2_ai_v2/controllers/power_controller.dart';
import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/repositories/game_repository.dart';
import 'package:d2_ai_v2/update_state_context/update_state_context_base.dart';
import 'package:d2_ai_v2/utils/cell_utils.dart';

import '../damage_scatter.dart';
import '../duration_controller.dart';
import 'attack_context.dart';

class AttackController {
  final PowerController powerController;
  final DamageScatter damageScatter;
  final GameRepository gameRepository;
  final AttackDurationController attackDurationController;

  Function(Unit unit)? onUnitAdd2Queue;

  RollConfig? rollConfig;

  /// Хеш, запоминающий оригинальных юнитов при превращении
  final Map<String, Unit> transformedUnitsCache = {};

  AttackController({
    required this.powerController,
    required this.damageScatter,
    required this.attackDurationController,
    required this.gameRepository,
  });

  AttackController deepCopy() {
    final copy = AttackController(
        powerController: powerController,
        damageScatter: damageScatter,
        attackDurationController: attackDurationController,
        gameRepository: gameRepository);

    for(var i in transformedUnitsCache.entries) {
      copy.transformedUnitsCache[i.key] = i.value.deepCopy();
    }

    return copy;
  }

  UpdateStateContextBase? updateStateContext;
  List<Unit>? units;

  /// Обновить сосстояние UI, если необходимо и если объект предоставлен
  //Future<void> onUpdate({int duration = 500}) async {
  Future<void> onUpdate({int duration = 100}) async {
    if (updateStateContext != null && units != null) {
      /*updateStateContext!
          .emit(updateStateContext!.state.copyWith(units: units));*/
      updateStateContext!.update(units: units);

      //switch(updateStateContext!.state.warScreenState) {
      switch (updateStateContext!.getWarScreenState()) {
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
    int current,
    int target,
    List<Unit> units,
    ResponseAction responseAction, {
    UpdateStateContextBase? updateStateContext,
    required Function(Unit unit) onAddUnit2Queue,
    required RollConfig rollConfig,
  }) async {
    this.rollConfig = rollConfig;
    this.updateStateContext = updateStateContext;
    this.units = units;
    onUnitAdd2Queue = onAddUnit2Queue;

    final _response = await _applyAttack(current, target, units);
    if (!_response.success) {
      return _response;
    }

    await onUpdate(duration: 1);

    return responseAction.copyWith(success: true);
  }

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

    final attackContext = AttackContext(
        current: current,
        target: target,
        units: units,
        topFrontLineEmpty: topFrontLineEmpty,
        botFrontLineEmpty: botFrontLineEmpty,
        cellHasUnit: cellHasUnit,
        isFirstAttack: true);

    return await _handleAttack(attackContext);
  }

  double getArmorRatio(Unit unit) {
    var armorRatio = 1.0 - unit.armor / 100.0;
    armorRatio /= (unit.isProtected ? 2.0 : 1.0);
    if (armorRatio < 0.1) {
      armorRatio = 0.1;
    }
    return armorRatio;
  }

  Future<ResponseAction> _handleAttack(AttackContext context) async {
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
        return await _handleBustDamage(context);
      case AttackClass.L_PETRIFY:
        return await _handlePetrify(context);
      case AttackClass.L_LOWER_DAMAGE:
        return await _handleLowerDamage(context);
      case AttackClass.L_LOWER_INITIATIVE:
        return await _handleLowerIni(context);
      case AttackClass.L_POISON:
        return await _handlePoison(context);
      case AttackClass.L_FROSTBITE:
        return await _handleFrostbite(context);
      case AttackClass.L_REVIVE:
        return await _handleRevive(context);
      case AttackClass.L_DRAIN_OVERFLOW:
        return await _handleDrainOverflow(context);
      case AttackClass.L_CURE:
        return await _handleCure(context);
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
        return await _handleTransformOther(context);
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
      {required int current, bool handlePower = true}) async {
    if (!handlePower) {
      await applyAttackToUnit(attack, target, units, current: current);
      if (attack2 != null) {
        await applyAttackToUnit(attack2, target, units, current: current);
      }
      return ResponseAction.success();
    }

    final rollMaxPower = checkIsTopTeam(current) && rollConfig!.topTeamMaxPower ||
        !checkIsTopTeam(current) && rollConfig!.bottomTeamMaxPower;

    if (powerController.applyAttack(attack,
        rollMaxPower: rollMaxPower)) {
      final responseAttack1 =
          await applyAttackToUnit(attack, target, units, current: current);

      if (units[target].isDead) {
        units[target] = units[target].copyWithDead();
        return ResponseAction.success();
      }

      if (attack2 != null) {
        if (powerController.applyAttack(attack2,
            rollMaxPower: rollMaxPower)) {
          final responseAttack2 = await applyAttackToUnit(
              attack2, target, units,
              current: current);
        } else {
          //print('Атака 2 промах!');
        }
      }
    } else {
      //print('Атака 1 промах!');
      units[target] = units[target].copyWith(uiInfo: 'Промах');
      await onUpdate();
    }

    return ResponseAction.success();
  }

  // DAMAGE BEGIN
  Future<ResponseAction> _handleDamage(AttackContext context) async {
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

  Future<ResponseAction> _handleOneTargetDamage(AttackContext context) async {
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
        currentUnit.unitAttack2, context.target, context.units, current: context.current);
  }

  Future<ResponseAction> _handleAnyTargetDamage(AttackContext context) async {
    final currentUnit = context.units[context.current];

    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam == targetUnitIsTopTeam) {
      return ResponseAction.error(
          'Юнит не может актаковать юнита из совей команды');
    }

    return await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units, current: context.current);
  }

  Future<ResponseAction> _handleAllTargetDamage(AttackContext context) async {
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
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units, current: context.current);
      }
    }
    return ResponseAction.success();
  }

// DAMAGE END
// HEAL START
  Future<ResponseAction> _handleHeal(AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam != targetUnitIsTopTeam) {
      return ResponseAction.error('Хил не может лечить врагов');
    }
    // Хилы могут воскрешать
    // todo Нв второй атаке, когда все фуловые, невозможнол ничего сделать
    if (currentUnit.unitAttack2?.attackClass == AttackClass.L_REVIVE) {
      if (targetUnit.revived) {
        if (targetUnit.currentHp <= 0) {
          return ResponseAction.error('Нельзя воскрешать уже воскрешённого');
        }
      }
    } else {
      if (targetUnit.isDead) {
        return ResponseAction.error('Хил не может лечить мёртвого');
      }
    }
    /*if (targetUnit.isDead
        && !(currentUnit.unitAttack2?.attackClass == AttackClass.L_REVIVE)
        && targetUnit.revived) {
      return ResponseAction.error('Хил не может лечить мёртвого либо юнит уже воскрешался');
    }*/
    if (targetUnit.isEmpty()) {
      return ResponseAction.error('Хил не может лечить пустого');
    }
    if (targetUnit.currentHp >= targetUnit.maxHp) {
      return ResponseAction.error('Хил не может лечить здорового');
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

  Future<ResponseAction> _handleAllTargetHeal(AttackContext context) async {
    final currentUnit = context.units[context.current];

    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    var i1 = targetUnitIsTopTeam ? 0 : 6;
    var i2 = targetUnitIsTopTeam ? 5 : 11;

    for (var i = 0; i < context.units.length; i++) {
      if (i >= i1 && i <= i2) {
        if (context.units[i].isEmpty() ||
            (context.units[i].isDead &&
                !(currentUnit.unitAttack2?.attackClass ==
                    AttackClass.L_REVIVE))) {
          continue;
        }
        final resp = await _applyAttacksToUnit(
            currentUnit.unitAttack, currentUnit.unitAttack2, i, context.units,
            handlePower: false, current: context.current);
      }
    }

    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAnyTargetHeal(AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        handlePower: false, current: context.current);
    return ResponseAction.success();
  }

// HEAL END
// DRAIN BEGIN

  Future<ResponseAction> _handleDrain(AttackContext context) async {
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

  Future<ResponseAction> _handleOneTargetDrain(AttackContext context) async {
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

  Future<ResponseAction> _handleAnyTargetDrain(AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAllTargetDrain(AttackContext context) async {
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

  Future<ResponseAction> _handleParalyze(AttackContext context) async {
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
    final targetUnitAttacks = targetUnit.attacksMap;
    if (targetUnitAttacks[AttackClass.L_PARALYZE] != null ||
        targetUnitAttacks[AttackClass.L_PETRIFY] != null) {
      return ResponseAction.error('Цель уже окаменена/парализована');
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

  Future<ResponseAction> _handleOneTargetParalyze(AttackContext context) async {
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

  Future<ResponseAction> _handleAllTargetParalyze(AttackContext context) async {
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

  Future<ResponseAction> _handleAnyTargetParalyze(AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// PARALYZE END
// FEAR START

  Future<ResponseAction> _handleFear(AttackContext context) async {
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

  Future<ResponseAction> _handleOneTargetFear(AttackContext context) async {
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

  Future<ResponseAction> _handleAllTargetFear(AttackContext context) async {
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

  Future<ResponseAction> _handleAnyTargetFear(AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// FEAR END
// POISON START

  Future<ResponseAction> _handlePoison(AttackContext context) async {
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

  Future<ResponseAction> _handleOneTargetPoison(AttackContext context) async {
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

  Future<ResponseAction> _handleAllTargetPoison(AttackContext context) async {
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

  Future<ResponseAction> _handleAnyTargetPoison(AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// POISON END
// BLISTER START

  Future<ResponseAction> _handleBlister(AttackContext context) async {
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

  Future<ResponseAction> _handleOneTargetBlister(AttackContext context) async {
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

  Future<ResponseAction> _handleAllTargetBlister(AttackContext context) async {
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

  Future<ResponseAction> _handleAnyTargetBlister(AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// BLISTER END
// L_FROSTBITE START

  Future<ResponseAction> _handleFrostbite(AttackContext context) async {
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
      AttackContext context) async {
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
      AttackContext context) async {
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
      AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// L_FROSTBITE END
// L_CURE START

  Future<ResponseAction> _handleCure(AttackContext context) async {
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

  /*Future<ResponseAction> _handleOneTargetCure(AttackContext context) async {
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

  Future<ResponseAction> _handleAllTargetCure(AttackContext context) async {
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

  Future<ResponseAction> _handleAnyTargetCure(AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current, handlePower: false);
    return ResponseAction.success();
  }

// L_CURE END
// L_LOWER_DAMAGE START

  Future<ResponseAction> _handleLowerDamage(AttackContext context) async {
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
      AttackContext context) async {
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
      AttackContext context) async {
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
      AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// L_LOWER_DAMAGE END
// L_SHATTER START

  Future<ResponseAction> _handleShatter(AttackContext context) async {
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

  Future<ResponseAction> _handleOneTargetShatter(AttackContext context) async {
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

  Future<ResponseAction> _handleAllTargetShatter(AttackContext context) async {
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

  Future<ResponseAction> _handleAnyTargetShatter(AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// L_SHATTER END

// L_REVIVE

  Future<ResponseAction> _handleRevive(AttackContext context) async {
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
      return ResponseAction.error('Невозможное действие над мёртвым юнитом');
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

  Future<ResponseAction> _handleAllTargetRevive(AttackContext context) async {
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

  Future<ResponseAction> _handleAnyTargetRevive(AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current, handlePower: false);
    return ResponseAction.success();
  }

//L_REVIVE END

// L_PETRIFY

  Future<ResponseAction> _handlePetrify(AttackContext context) async {
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
    final targetUnitAttacks = targetUnit.attacksMap;
    if (targetUnitAttacks[AttackClass.L_PARALYZE] != null ||
        targetUnitAttacks[AttackClass.L_PETRIFY] != null) {
      return ResponseAction.error('Цель уже окаменена/парализована');
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

  Future<ResponseAction> _handleOneTargetPetrify(AttackContext context) async {
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

  Future<ResponseAction> _handleAllTargetPetrify(AttackContext context) async {
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

  Future<ResponseAction> _handleAnyTargetPetrify(AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// L_PETRIFY END

// L_LOWER_INITIATIVE

  Future<ResponseAction> _handleLowerIni(AttackContext context) async {
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
    final targetUnitAttacks = targetUnit.attacksMap;
    if (targetUnitAttacks[AttackClass.L_LOWER_INITIATIVE] != null) {
      return ResponseAction.error('У цели уже снижена инициатива');
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

  Future<ResponseAction> _handleOneTargetLowerIni(AttackContext context) async {
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

  Future<ResponseAction> _handleAllTargetLowerIni(AttackContext context) async {
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

  Future<ResponseAction> _handleAnyTargetLowerIni(AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// L_LOWER_INITIATIVE END

// L_GIVE_ATTACK

  Future<ResponseAction> _handleGiveAttack(AttackContext context) async {
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
    final targetUnitAttacks = targetUnit.attacksMap;
    if (targetUnitAttacks[AttackClass.L_GIVE_ATTACK] != null) {
      return ResponseAction.error('У цели уже повышен урон');
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
      AttackContext context) async {
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
      AttackContext context) async {
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
      AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current, handlePower: false);
    return ResponseAction.success();
  }

// L_GIVE_ATTACK END

// L_BOOST_DAMAGE

  Future<ResponseAction> _handleBustDamage(AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (context.current == context.target) {
      return ResponseAction.error('Себе давать атаку нельзя');
    }

    if (currentUnitIsTopTeam != targetUnitIsTopTeam) {
      return ResponseAction.error('Чужим давать атакоу нельзя');
    }
    if (targetUnit.isDead || targetUnit.isEmpty()) {
      return ResponseAction.error(
          'Невозможное действие над мёртвым/пустым юнитом');
    }
    final targetUnitAttacks = targetUnit.attacksMap;
    if (targetUnitAttacks[AttackClass.L_BOOST_DAMAGE] != null) {
      return ResponseAction.error('У цели уже повышен урон');
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
      AttackContext context) async {
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
      AttackContext context) async {
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
      AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current, handlePower: false);
    return ResponseAction.success();
  }

// L_BOOST_DAMAGE END

// L_DRAIN_OVERFLOW

  Future<ResponseAction> _handleDrainOverflow(AttackContext context) async {
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
      AttackContext context) async {
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
      AttackContext context) async {
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
      AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// L_DRAIN_OVERFLOW END
// L_TRANSFORM_OTHER BEGIN

  Future<ResponseAction> _handleTransformOther(AttackContext context) async {
    final currentUnitAttack = context.units[context.current].unitAttack;
    final currentUnit = context.units[context.current];
    final targetUnit = context.units[context.target];
    final currentUnitIsTopTeam = checkIsTopTeam(context.current);
    final targetUnitIsTopTeam = checkIsTopTeam(context.target);

    if (currentUnitIsTopTeam == targetUnitIsTopTeam) {
      return ResponseAction.error('Своих превращать нельзя');
    }
    if (targetUnit.isDead || targetUnit.isEmpty()) {
      return ResponseAction.error(
          'Невозможное действие над мёртвым/пустым юнитом');
    }
    // Если юнит уже превращён, превратить его снова нельзя
    if (targetUnit.transformed) {
      return ResponseAction.error('Юнит уже превращён');
    }
    switch (currentUnitAttack.targetsCount) {
      case TargetsCount.one:
        return await _handleOneTargetTransformOther(context);

      case TargetsCount.all:
        return await _handleAllTargetTransformOther(context);

      case TargetsCount.any:
        return await _handleAnyTargetTransformOther(context);
    }
  }

  Future<ResponseAction> _handleOneTargetTransformOther(
      AttackContext context) async {
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
          'Юнит ${currentUnit.unitName} не может превратить юнита ${targetUnit.unitName}');
    }

    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

  Future<ResponseAction> _handleAllTargetTransformOther(
      AttackContext context) async {
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

  Future<ResponseAction> _handleAnyTargetTransformOther(
      AttackContext context) async {
    final currentUnit = context.units[context.current];
    final resp = await _applyAttacksToUnit(currentUnit.unitAttack,
        currentUnit.unitAttack2, context.target, context.units,
        current: context.current);
    return ResponseAction.success();
  }

// L_TRANSFORM_OTHER END
}
