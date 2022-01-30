
import 'package:benchmark/benchmark.dart';
import 'package:d2_ai_v2/controllers/attack_controller/attack_controller.dart';
import 'package:d2_ai_v2/controllers/damage_scatter.dart';
import 'package:d2_ai_v2/controllers/duration_controller.dart';
import 'package:d2_ai_v2/controllers/game_controller/actions.dart';
import 'package:d2_ai_v2/controllers/game_controller/roll_config.dart';
import 'package:d2_ai_v2/controllers/imunne_controller.dart';
import 'package:d2_ai_v2/controllers/power_controller.dart';
import 'package:d2_ai_v2/models/g_immu/g_immu_provider.dart';
import 'package:d2_ai_v2/models/g_immu_c/g_immu_c_provider.dart';
import 'package:d2_ai_v2/models/providers.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/repositories/game_repository.dart';
import 'package:d2_ai_v2/test_units_factory.dart';
import 'package:d2_ai_v2/utils/math_utils.dart';



/*void main() {

  final powerController = PowerController(randomExponentialDistribution: RandomExponentialDistribution());
  final damageScatter = DamageScatter(randomExponentialDistribution: RandomExponentialDistribution());
  final attackDurationController = AttackDurationController();

  final gameRepository = GameRepository(
      gunitsProvider: GunitsProvider(),
      tglobalProvider: TglobalProvider(),
      gattacksProvider: GattacksProvider(),
      gtransfProvider: GtransfProvider(),
      gDynUpgrProvider: GDynUpgrProvider(),
      gimmuProvider: GimmuProvider(),
      gimmuCProvider: GimmuCProvider())..init();

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
    GameRepository.globalEmptyUnit,
    GameRepository.globalEmptyUnit,
    GameRepository.globalEmptyUnit,
    GameRepository.globalEmptyUnit,
    TestUnitsFactory.getTestUnitDamager(),
    GameRepository.globalEmptyUnit,

    GameRepository.globalEmptyUnit,
    TestUnitsFactory.getTestUnitDamager(),
    GameRepository.globalEmptyUnit,
    GameRepository.globalEmptyUnit,
    GameRepository.globalEmptyUnit,
    GameRepository.globalEmptyUnit,
  ];
  final responseAction = ResponseAction(
      message: '',
      success: true,
      endGame: false);

  units[7].currentHp = 1000;

  benchmark('attackController.applyAttack. Unit damager', () async {

    for(var i=0; i<20000; i++ ) {
      var attackResponse = await attackController.applyAttack(
          4,
          7,
          units,
          responseAction,
          onAddUnit2Queue: (u) {},
          rollConfig: rollConfig);
    }

  });

}*/
