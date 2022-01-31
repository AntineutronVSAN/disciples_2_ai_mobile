import 'package:d2_ai_v2/controllers/attack_controller/attack_controller.dart';
import 'package:d2_ai_v2/controllers/attack_controller/postprocessing_part/postprocessing_part.dart';
import 'package:d2_ai_v2/controllers/attack_controller/preprocessing_part/preprocessing_part.dart';
import 'package:d2_ai_v2/controllers/damage_scatter.dart';
import 'package:d2_ai_v2/controllers/duration_controller.dart';
import 'package:d2_ai_v2/controllers/game_controller/actions.dart';
import 'package:d2_ai_v2/controllers/game_controller/roll_config.dart';
import 'package:d2_ai_v2/controllers/imunne_controller.dart';
import 'package:d2_ai_v2/controllers/power_controller.dart';
import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/repositories/game_repository_base.dart';
import 'package:d2_ai_v2/repositories/test_game_repository.dart';
import 'package:d2_ai_v2/utils/math_utils.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:d2_ai_v2/test_units_factory.dart';

void main() {
  final powerController = PowerController(
      randomExponentialDistribution: RandomExponentialDistribution());
  final damageScatter = DamageScatter(
      randomExponentialDistribution: RandomExponentialDistribution());
  final attackDurationController = AttackDurationController();

  final gameRepository = TestGameRepository();

  final immuneController = ImmuneController();

  final rollConfig = RollConfig(
      topTeamMaxPower: true,
      bottomTeamMaxPower: true,
      topTeamMaxIni: true,
      bottomTeamMaxIni: true,
      bottomTeamMaxDamage: true,
      topTeamMaxDamage: true);

  test('ATTACK CONTROLLER DAMAGE TEST', () async {
    final AttackController attackController = AttackController(
        powerController: powerController,
        damageScatter: damageScatter,
        attackDurationController: attackDurationController,
        gameRepository: gameRepository,
        immuneController: immuneController);
    final List<Unit> units = [
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      TestUnitsFactory.getTestUnitDamager(),
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      TestUnitsFactory.getTestUnitDamager(),
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
    ];
    final responseAction =
        ResponseAction(message: '', success: true, endGame: false);
    var attackResponse = await attackController.applyAttack(
        4, 7, units, responseAction,
        onAddUnit2Queue: (u) {}, rollConfig: rollConfig);
    expect(attackResponse.success, true,
        reason: 'Юнит может ударять. Сообщение - ${responseAction.message}');
    expect(
        units[7].currentHp ==
            units[7].maxHp -
                units[4].unitAttack.damage -
                DamageScatter.maxScatterValue,
        true,
        reason:
            'Неверно посчитан урон ${units[7].currentHp} != ${units[7].maxHp} - (${units[4].unitAttack.damage} + ${DamageScatter.maxScatterValue})');
    final currentUnitHp = units[7].currentHp;
    attackResponse = await attackController.applyAttack(
        4, 7, units, responseAction,
        onAddUnit2Queue: (u) {}, rollConfig: rollConfig);
    expect(attackResponse.success, true,
        reason: 'Юнит может ударять. Сообщение - ${responseAction.message}');
    expect(
        units[7].currentHp ==
            currentUnitHp -
                units[4].unitAttack.damage -
                DamageScatter.maxScatterValue,
        true,
        reason:
            'Неверно посчитан урон ${units[7].currentHp} != $currentUnitHp - (${units[4].unitAttack.damage} + ${DamageScatter.maxScatterValue})');
    attackResponse = await attackController.applyAttack(
        4, 8, units, responseAction,
        onAddUnit2Queue: (u) {}, rollConfig: rollConfig);
    expect(attackResponse.success, false,
        reason: 'Юнит не может ударять. Сообщение - ${responseAction.message}');
  });

  test('attack controller damage and init lower test', () async {
    final AttackController attackController = AttackController(
        powerController: powerController,
        damageScatter: damageScatter,
        attackDurationController: attackDurationController,
        gameRepository: gameRepository,
        immuneController: immuneController);
    final List<Unit> units = [
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      TestUnitsFactory.getTestLowerDamagerAndInitiative(),
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      TestUnitsFactory.getTestUnitDamager(),
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
    ];
    final responseAction =
        ResponseAction(message: '', success: true, endGame: false);
    var attackResponse = await attackController.applyAttack(
        4, 7, units, responseAction,
        onAddUnit2Queue: (u) {}, rollConfig: rollConfig);
    expect(attackResponse.success, true,
        reason: 'Юнит может ударять. Сообщение - ${responseAction.message}');

    expect(units[7].attacksMap[AttackClass.L_LOWER_INITIATIVE] != null, true,
        reason: '');
    expect(units[7].attacksMap[AttackClass.L_LOWER_DAMAGE] != null, true,
        reason: '');
    expect(units[7].attacksMap.length, 2, reason: '');

    // Имитация начала хода юнита, на которого наложилась атака
    final res = await attackController.unitMovePreprocessing(7, units,
        waiting: false, protecting: false, retriting: false);

    expect(res, true, reason: '');
    expect(units[7].attacksMap[AttackClass.L_LOWER_INITIATIVE] != null, true,
        reason: 'Иня не должна спадать сразу');
    expect(units[7].attacksMap[AttackClass.L_LOWER_DAMAGE] != null, true,
        reason: '');

    expect(
        units[7].unitAttack.damage,
        units[7].unitAttack.attackConstParams.firstDamage -
            (units[7].unitAttack.attackConstParams.firstDamage * 0.5).toInt(),
        reason: 'Dam');
    expect(units[7].unitAttack.initiative,
        units[7].unitAttack.attackConstParams.firstInitiative ~/ 2,
        reason: 'Ini');

    // Имитация конца хода юнита, на которого наложилась атака
    await attackController.unitMovePostProcessing(7, units,
        waiting: false, protecting: false, retriting: false);

    expect(units[7].attacksMap[AttackClass.L_LOWER_INITIATIVE] == null, true,
        reason: 'Дебаф ини должен спасть');
    expect(units[7].attacksMap[AttackClass.L_LOWER_DAMAGE] == null, true,
        reason: 'Дебаф дамага должен спасть');

    expect(units[7].unitAttack.damage,
        units[7].unitAttack.attackConstParams.firstDamage,
        reason: 'Dam f');
    expect(units[7].unitAttack.initiative,
        units[7].unitAttack.attackConstParams.firstInitiative,
        reason: 'Ini f');
  });

  test('ATTACK CONTROLLER TRANSFORM OTHER TEST', () async {
    final AttackController attackController = AttackController(
        powerController: powerController,
        damageScatter: damageScatter,
        attackDurationController: attackDurationController,
        gameRepository: gameRepository,
        immuneController: immuneController);
    final List<Unit> units = [
      TestUnitsFactory.getUnitTransformer(), // 0
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      TestUnitsFactory.getTestLowerDamagerAndInitiative(), // 4
      GameRepositoryBase.globalEmptyUnit,

      GameRepositoryBase.globalEmptyUnit,
      TestUnitsFactory.getTestUnitDamager(), // 7
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      TestUnitsFactory.getDamageBuster(), // 11
    ];
    final responseAction =
        ResponseAction(message: '', success: true, endGame: false);
    // Тестовый кейс:
    // 11 -> 7
    // 4 -> 7
    // 0 -> 7
    // Вернуть форму 7, проверить все параметры

    // 11 -> 7
    var attackResponse = await attackController.applyAttack(
        11, 7, units, responseAction,
        onAddUnit2Queue: (u) {}, rollConfig: rollConfig);
    expect(attackResponse.success, true,
        reason:
            'Юнит может повысить урон. Сообщение - ${responseAction.message}');

    expect(
        units[7].unitAttack.damage,
        units[7].unitAttack.attackConstParams.firstDamage +
            (units[7].unitAttack.attackConstParams.firstDamage * 0.75).toInt(),
        reason: 'Неврно высчитано повышение урона');
    expect(units[7].attacksMap[AttackClass.L_BOOST_DAMAGE] != null, true,
        reason: 'Повышение урона должно висеть на юните');

    attackResponse = await attackController.applyAttack(
        11, 7, units, responseAction,
        onAddUnit2Queue: (u) {}, rollConfig: rollConfig);
    expect(attackResponse.success, false,
        reason:
            'Юнит не может повысить урон. Сообщение - ${responseAction.message}');

    // 4 -> 7
    attackResponse = await attackController.applyAttack(
        4, 7, units, responseAction,
        onAddUnit2Queue: (u) {}, rollConfig: rollConfig);
    expect(attackResponse.success, true,
        reason: 'Сообщение - ${responseAction.message}');

    //expect(units[7].unitAttack.damage, units[7].unitAttack.firstDamage + (units[7].unitAttack.firstDamage * 0.75).toInt(), reason: 'Неврно высчитано повышение урона');
    expect(units[7].attacksMap[AttackClass.L_BOOST_DAMAGE] != null, true,
        reason: 'Повышение урона должно висеть на юните');
    expect(units[7].attacksMap[AttackClass.L_LOWER_DAMAGE] != null, true,
        reason: 'Понижение урона должно висеть на юните');
    expect(units[7].attacksMap[AttackClass.L_LOWER_INITIATIVE] != null, true,
        reason: 'Понижение ини должно висеть на юните');

    expect(units[7].unitAttack.initiative,
        units[7].unitAttack.attackConstParams.firstInitiative ~/ 2,
        reason: 'Ini');

    expect(
        units[7].unitAttack.damage,
        units[7].unitAttack.attackConstParams.firstDamage +
            (units[7].unitAttack.attackConstParams.firstDamage * 0.75).toInt() -
            (units[7].unitAttack.attackConstParams.firstDamage * 0.5).toInt(),
        reason: 'Неврно высчитано повышение урона');

    /*attackResponse = await attackController.applyAttack(
        4,
        7,
        units,
        responseAction,
        onAddUnit2Queue: (u) {},
        rollConfig: rollConfig);
    expect(attackResponse.success, false, reason: '');*/ // TODO

    // 0 -> 7
    attackResponse = await attackController.applyAttack(
        0, 7, units, responseAction,
        onAddUnit2Queue: (u) {}, rollConfig: rollConfig);
    expect(attackResponse.success, true,
        reason: 'Сообщение - ${responseAction.message}');

    expect(units[7].attacksMap[AttackClass.L_BOOST_DAMAGE] != null, true,
        reason: 'должно висеть на юните');
    expect(units[7].attacksMap[AttackClass.L_LOWER_DAMAGE] != null, true,
        reason: 'должно висеть на юните');
    expect(units[7].attacksMap[AttackClass.L_LOWER_INITIATIVE] != null, true,
        reason: 'должно висеть на юните');
    expect(units[7].attacksMap[AttackClass.L_TRANSFORM_OTHER] != null, true,
        reason: 'должно висеть на юните');

    expect(units[7].unitAttack.initiative, testUnitInit ~/ 2, reason: '');
    expect(
        units[7].unitAttack.damage,
        testUnitDamage +
            (testUnitDamage * 0.75).toInt() -
            (testUnitDamage * 0.5).toInt(),
        reason: 'Неврно высчитано повышение урона');

    // Имитация хода юнита
    final resp = await attackController.unitMovePreprocessing(7, units,
        waiting: false, protecting: false, retriting: false);
    expect(resp, true, reason: '');

    expect(units[7].attacksMap[AttackClass.L_BOOST_DAMAGE] != null, true,
        reason: 'должно висеть на юните');
    expect(units[7].attacksMap[AttackClass.L_LOWER_DAMAGE] != null, true,
        reason: 'должно висеть на юните');
    expect(units[7].attacksMap[AttackClass.L_LOWER_INITIATIVE] != null, true,
        reason: 'должно висеть на юните');
    expect(units[7].attacksMap[AttackClass.L_TRANSFORM_OTHER] == null, true,
        reason: 'должно висеть на юните');

    // TODO Внимание, тут хардкод параметров дамагера TestUnitsFactory.getTestUnitDamager()
    // если в фабрике юнитов их изменить, необходимо изменить и тут, иначе тест
    // не будет пройден
    expect(units[7].unitAttack.initiative, 50 ~/ 2, reason: '');
    expect(units[7].unitAttack.damage,
        25 + (25 * 0.75).toInt() - (25 * 0.5).toInt(),
        reason: 'Неврно высчитано повышение урона');

    // Имитация конца хода юнита
    await attackController.unitMovePostProcessing(7, units,
        waiting: false, protecting: false, retriting: false);
    expect(resp, true, reason: '');

    expect(units[7].attacksMap[AttackClass.L_BOOST_DAMAGE] == null, true,
        reason: 'должно висеть на юните');
    expect(units[7].attacksMap[AttackClass.L_LOWER_DAMAGE] == null, true,
        reason: 'должно висеть на юните');
    expect(units[7].attacksMap[AttackClass.L_LOWER_INITIATIVE] == null, true,
        reason: 'должно висеть на юните');
    expect(units[7].attacksMap[AttackClass.L_TRANSFORM_OTHER] == null, true,
        reason: 'должно висеть на юните');

    expect(units[7].unitAttack.initiative, 50, reason: '');
    expect(units[7].unitAttack.damage, 25,
        reason: 'Неврно высчитано повышение урона');
  });

  test('ATTACK CONTROLLER immune once and damage', () async {
    final AttackController attackController = AttackController(
        powerController: powerController,
        damageScatter: damageScatter,
        attackDurationController: attackDurationController,
        gameRepository: gameRepository,
        immuneController: immuneController);
    final List<Unit> units = [
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      TestUnitsFactory.getDamagerWithOnceImmuneSelf(), // 3
      TestUnitsFactory.getDamagerWithOnceImmuneSelf(), // 4
      TestUnitsFactory.getDamagerWithOnceImmuneSelf(), // 5

      TestUnitsFactory.getDamagerWithOnceImmuneSelf(), // 6
      TestUnitsFactory.getDamagerWithOnceImmuneSelf(), // 7
      TestUnitsFactory.getDamagerWithOnceImmuneSelf(), // 8
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
    ];
    final responseAction =
        ResponseAction(message: '', success: true, endGame: false);

    var resp = await attackController.applyAttack(3, 8, units, responseAction,
        onAddUnit2Queue: (u) {}, rollConfig: rollConfig);
    expect(resp.success, false,
        reason: 'Сообщение - ${responseAction.message}');
    resp = await attackController.applyAttack(8, 3, units, responseAction,
        onAddUnit2Queue: (u) {}, rollConfig: rollConfig);
    expect(resp.success, false,
        reason: 'Сообщение - ${responseAction.message}');

    // Тестовые кейсы
    // 3 -> 6
    // 3 -> 7
    // 8 -> 4
    // 8 -> 5
    // 6 -> 4
    // 4 -> 7

    // 3-6
    resp = await attackController.applyAttack(3, 6, units, responseAction,
        onAddUnit2Queue: (u) {}, rollConfig: rollConfig);
    expect(resp.success, true, reason: 'Сообщение - ${responseAction.message}');

    expect(units[6].currentHp, units[6].maxHp, reason: '');
    expect(units[6].hasSourceImunne[testDamagerWithOnceImmuneSelfSource], false,
        reason: 'Защита должна сняться');

    // 3-7
    resp = await attackController.applyAttack(3, 7, units, responseAction,
        onAddUnit2Queue: (u) {}, rollConfig: rollConfig);
    expect(resp.success, true, reason: 'Сообщение - ${responseAction.message}');

    expect(units[7].currentHp, units[7].maxHp, reason: '');
    expect(units[7].hasSourceImunne[testDamagerWithOnceImmuneSelfSource], false,
        reason: 'Защита должна сняться');

    // 8 -> 4
    resp = await attackController.applyAttack(8, 4, units, responseAction,
        onAddUnit2Queue: (u) {}, rollConfig: rollConfig);
    expect(resp.success, true, reason: 'Сообщение - ${responseAction.message}');

    expect(units[4].currentHp, units[4].maxHp, reason: '');
    expect(units[4].hasSourceImunne[testDamagerWithOnceImmuneSelfSource], false,
        reason: 'Защита должна сняться');

    // 6 -> 4
    resp = await attackController.applyAttack(6, 4, units, responseAction,
        onAddUnit2Queue: (u) {}, rollConfig: rollConfig);
    expect(resp.success, true, reason: 'Сообщение - ${responseAction.message}');

    expect(
        units[4].currentHp,
        testDamagerWithOnceImmuneSelfHp -
            testDamagerWithOnceImmuneSelfDamage -
            DamageScatter.maxScatterValue,
        reason: '');

    // 8 -> 5
    resp = await attackController.applyAttack(8, 5, units, responseAction,
        onAddUnit2Queue: (u) {}, rollConfig: rollConfig);
    expect(resp.success, true, reason: 'Сообщение - ${responseAction.message}');

    expect(units[5].currentHp, units[5].maxHp, reason: '');
    expect(units[5].hasSourceImunne[testDamagerWithOnceImmuneSelfSource], false,
        reason: 'Защита должна сняться');

    // 4 -> 7
    resp = await attackController.applyAttack(4, 7, units, responseAction,
        onAddUnit2Queue: (u) {}, rollConfig: rollConfig);
    expect(resp.success, true, reason: 'Сообщение - ${responseAction.message}');
    expect(
        units[7].currentHp,
        testDamagerWithOnceImmuneSelfHp -
            testDamagerWithOnceImmuneSelfDamage -
            DamageScatter.maxScatterValue,
        reason: '');
    resp = await attackController.applyAttack(4, 7, units, responseAction,
        onAddUnit2Queue: (u) {}, rollConfig: rollConfig);
    expect(resp.success, true, reason: 'Сообщение - ${responseAction.message}');

    expect(
        units[7].currentHp,
        testDamagerWithOnceImmuneSelfHp -
            testDamagerWithOnceImmuneSelfDamage * 2 -
            DamageScatter.maxScatterValue * 2,
        reason: '');
  });
}
