
import 'dart:math';

import 'package:benchmark/benchmark.dart';
import 'package:d2_ai_v2/const.dart';
import 'package:d2_ai_v2/controllers/attack_controller/attack_controller.dart';
import 'package:d2_ai_v2/controllers/attack_controller/postprocessing_part/postprocessing_part.dart';
import 'package:d2_ai_v2/controllers/attack_controller/preprocessing_part/preprocessing_part.dart';
import 'package:d2_ai_v2/controllers/damage_scatter.dart';
import 'package:d2_ai_v2/controllers/duration_controller.dart';
import 'package:d2_ai_v2/controllers/game_controller/actions.dart';
import 'package:d2_ai_v2/controllers/game_controller/roll_config.dart';
import 'package:d2_ai_v2/controllers/imunne_controller.dart';
import 'package:d2_ai_v2/controllers/power_controller.dart';
import 'package:d2_ai_v2/d2_entities/unit/unit_provider.dart';
import 'package:d2_ai_v2/models/g_immu/g_immu_provider.dart';
import 'package:d2_ai_v2/models/g_immu_c/g_immu_c_provider.dart';
import 'package:d2_ai_v2/models/providers.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/repositories/game_repository.dart';
import 'package:d2_ai_v2/repositories/game_repository_base.dart';
import 'package:d2_ai_v2/test_units_factory.dart';
import 'package:d2_ai_v2/utils/math_utils.dart';


void main() {
  final GameRepository gameRepository = GameRepository(
      gunitsProvider: DBFObjectsProvider(assetsPath: smnsD2UnitsProviderAssetPath, idKey: smnsD2UnitsProviderIDkey),
      tglobalProvider: TglobalProvider(),
      gattacksProvider: DBFObjectsProvider(assetsPath: smnsD2AttacksProviderAssetPath, idKey: smnsD2AttacksProviderIDkey),
      gtransfProvider: DBFObjectsProvider(assetsPath: smnsD2TransfProviderAssetPath, idKey: smnsD2TransfProviderIDkey),
      gDynUpgrProvider: GDynUpgrProvider(),
      gimmuProvider: GimmuProvider(),
      gimmuCProvider: GimmuCProvider())..init();

  final Unit testUnit = gameRepository.getRandomUnit();


  benchmark('Unit.deepCopy()', () {

    for(var i=0; i<2000000; i++ ) {
      testUnit.deepCopy();
    }
  });

  benchmark('Unit.copywith(isMoving: false)', () {

    for(var i=0; i<2000000; i++ ) {
      testUnit.copyWith(isMoving: false);
    }
  });
  benchmark('Unit.isMoving = false)', () {

    for(var i=0; i<2000000; i++ ) {
      testUnit.isMoving = false;
    }
  });


  final powerController = PowerController(randomExponentialDistribution: RandomExponentialDistribution());
  final damageScatter = DamageScatter(randomExponentialDistribution: RandomExponentialDistribution());
  final attackDurationController = AttackDurationController();

  final immuneController = ImmuneController();

  final rollConfig = RollConfig(
      topTeamMaxPower: true,
      bottomTeamMaxPower: true,
      topTeamMaxIni: true,
      bottomTeamMaxIni: true,
      bottomTeamMaxDamage: true,
      topTeamMaxDamage: true);

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

  units[7].currentHp = 100000;

  benchmark('!!!attackController.applyAttack. Unit damager', () {
    for(var i=0; i<2000; i++ ) {

    var attackResponse = attackController.applyAttack(
        4,
        7,
        units,
        responseAction,
        onAddUnit2Queue: (u) {},
        rollConfig: rollConfig);
    }

  });
  /*benchmark('!!!attackController.applyAttack. Unit damager', () {
    for(var i=0; i<2000; i++ ) {

      var attackResponse = attackController.applyAttackFast(
          4,
          7,
          units,
          responseAction,
          onAddUnit2Queue: (u) {},
          rollConfig: rollConfig);
    }

  });*/

  benchmark('attackController.unitMovePreprocessing. Unit damager', () {
    for(var i=0; i<1000; i++ ) {
      var attackResponse = attackController.unitMovePreprocessing(7, units,
          waiting: false, protecting: false, retriting: false);
    }
    }
  );
  benchmark('attackController.unitMovePostprocessing. Unit damager', () {
    for(var i=0; i<1000; i++ ) {
    var attackResponse = attackController.unitMovePostProcessing(7, units,
        waiting: false, protecting: false, retriting: false);
    }

  });

  benchmark('random.nextInt', () {
    final random = Random();
    for(var i=0; i<200000; i++ ) {
      final val = random.nextInt(100);
    }

  });

  benchmark('Create final string variable', () {
    for(var i=0; i<5000000; i++ ) {
      final val = 'asdfjasdfljkasdfasdfasdfasdfasdf';
    }
  });
  benchmark('Create var string variable', () {
    for(var i=0; i<5000000; i++ ) {
      var val = 'asdfjasdfljkasdfasdfasdfasdfasdf';
    }
  });
  benchmark('Create const string variable', () {
    for(var i=0; i<5000000; i++ ) {
      const val = 'asdfjasdfljkasdfasdfasdfasdfasdf';
    }
  });
  benchmark('Create var bool variable', () {
    for(var i=0; i<5000000; i++ ) {
      var val = true;
    }
  });
  benchmark('Create final bool variable', () {
    for(var i=0; i<5000000; i++ ) {
      final val = true;
    }
  });
  benchmark('Create const bool variable', () {
    for(var i=0; i<5000000; i++ ) {
      final val = true;
    }
  });
  benchmark('Create final ResponseAction variable', () {
    for(var i=0; i<5000000; i++ ) {
      final val = ResponseAction(
          message: 'ajsdfhaklsdflkasdfjlkasdjflkasdflkasjdf',
          success: false,
          endGame: true);
    }
  });
  benchmark('Create var ResponseAction variable', () {
    for(var i=0; i<5000000; i++ ) {
      var val = ResponseAction(
          message: 'ajsdfhaklsdflkasdfjlkasdjflkasdflkasjdf',
          success: false,
          endGame: true);
    }
  });

}
