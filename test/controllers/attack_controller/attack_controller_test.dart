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

import '../../../lib/test_units_factory.dart';


void main() {

  final powerController = PowerController(randomExponentialDistribution: RandomExponentialDistribution());
  final damageScatter = DamageScatter(randomExponentialDistribution: RandomExponentialDistribution());
  final attackDurationController = AttackDurationController();

  final gameRepository = TestGameRepository();

  /*final gameRepository = GameRepository(
      gunitsProvider: GunitsProvider(),
      tglobalProvider: TglobalProvider(),
      gattacksProvider: GattacksProvider(),
      gtransfProvider: GtransfProvider(),
      gDynUpgrProvider: GDynUpgrProvider(),
      gimmuProvider: GimmuProvider(),
      gimmuCProvider: GimmuCProvider())..init();*/

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
    final responseAction = ResponseAction(
        message: '',
        success: true,
        endGame: false);
    var attackResponse = await attackController.applyAttack(
        4,
        7,
        units,
        responseAction,
        onAddUnit2Queue: (u) {},
        rollConfig: rollConfig);
    expect(attackResponse.success, true, reason: 'Юнит может ударять. Сообщение - ${responseAction.message}');
    expect(
        units[7].currentHp == units[7].maxHp - units[4].unitAttack.damage - DamageScatter.maxScatterValue, true,
        reason: 'Неверно посчитан урон ${units[7].currentHp} != ${units[7].maxHp} - (${units[4].unitAttack.damage} + ${DamageScatter.maxScatterValue})'
    );
    final currentUnitHp = units[7].currentHp;
    attackResponse = await attackController.applyAttack(
        4,
        7,
        units,
        responseAction,
        onAddUnit2Queue: (u) {},
        rollConfig: rollConfig);
    expect(attackResponse.success, true, reason: 'Юнит может ударять. Сообщение - ${responseAction.message}');
    expect(
        units[7].currentHp == currentUnitHp - units[4].unitAttack.damage - DamageScatter.maxScatterValue, true,
        reason: 'Неверно посчитан урон ${units[7].currentHp} != $currentUnitHp - (${units[4].unitAttack.damage} + ${DamageScatter.maxScatterValue})'
    );
    attackResponse = await attackController.applyAttack(
        4,
        8,
        units,
        responseAction,
        onAddUnit2Queue: (u) {},
        rollConfig: rollConfig);
    expect(attackResponse.success, false, reason: 'Юнит не может ударять. Сообщение - ${responseAction.message}');
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
    final responseAction = ResponseAction(
        message: '',
        success: true,
        endGame: false);
    var attackResponse = await attackController.applyAttack(
        4,
        7,
        units,
        responseAction,
        onAddUnit2Queue: (u) {},
        rollConfig: rollConfig);
    expect(attackResponse.success, true, reason: 'Юнит может ударять. Сообщение - ${responseAction.message}');

    expect(units[7].attacksMap[AttackClass.L_LOWER_INITIATIVE] != null, true, reason: '');
    expect(units[7].attacksMap[AttackClass.L_LOWER_DAMAGE] != null, true, reason: '');
    expect(units[7].attacksMap.length, 2, reason: '');

    // Имитация начала хода юнита, на которого наложилась атака
    final res = await attackController.unitMovePreprocessing(
        7, units,
        waiting: false, protecting: false, retriting: false);

    expect(res, true, reason: '');
    expect(units[7].attacksMap[AttackClass.L_LOWER_INITIATIVE] != null, true, reason: 'Иня не должна спадать сразу');
    expect(units[7].attacksMap[AttackClass.L_LOWER_DAMAGE] != null, true, reason: '');

    expect(units[7].unitAttack.damage, units[7].unitAttack.firstDamage - (units[7].unitAttack.firstDamage * 0.5).toInt(), reason: 'Dam');
    expect(units[7].unitAttack.initiative, units[7].unitAttack.firstInitiative ~/ 2, reason: 'Ini');

    // Имитация конца хода юнита, на которого наложилась атака
    await attackController.unitMovePostProcessing(
        7, units,
        waiting: false, protecting: false, retriting: false);

    expect(units[7].attacksMap[AttackClass.L_LOWER_INITIATIVE] == null, true, reason: 'Дебаф ини должен спасть');
    expect(units[7].attacksMap[AttackClass.L_LOWER_DAMAGE] == null, true, reason: 'Дебаф дамага должен спасть');

    expect(units[7].unitAttack.damage, units[7].unitAttack.firstDamage, reason: 'Dam f');
    expect(units[7].unitAttack.initiative, units[7].unitAttack.firstInitiative, reason: 'Ini f');

  });


  test('ATTACK CONTROLLER TRANSFORM OTHER TEST', () async {

  });

}