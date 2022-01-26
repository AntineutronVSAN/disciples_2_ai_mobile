import 'package:collection/src/iterable_extensions.dart';
import 'package:d2_ai_v2/ai_controller/ai_contoller.dart';
import 'package:d2_ai_v2/dart_nural/networks/linear_network_v2.dart';
import 'package:d2_ai_v2/models/providers.dart';
import 'package:d2_ai_v2/optim_algorythm/factories/neat_factory.dart';
import 'package:d2_ai_v2/optim_algorythm/factories/networks_factory.dart';
import 'package:d2_ai_v2/providers/dart_file_provider.dart';
import 'package:d2_ai_v2/repositories/game_repository.dart';
import 'package:d2_ai_v2/units_pack.dart';
import 'package:d2_ai_v2/utils/math_utils.dart';
import 'const.dart';
import 'controllers/attack_controller/attack_controller.dart';
import 'controllers/damage_scatter.dart';
import 'controllers/duration_controller.dart';
import 'controllers/game_controller/game_controller.dart';
import 'controllers/imunne_controller.dart';
import 'controllers/initiative_shuffler.dart';
import 'controllers/power_controller.dart';
import 'models/g_immu/g_immu_provider.dart';
import 'models/g_immu_c/g_immu_c_provider.dart';
import 'models/unit.dart';
import 'optim_algorythm/genetic_controller.dart';

/*

Файл для запуска генетического алгоритма отдельно от всего приложения

*/



void main(List<String> arguments) async {

  await startOnlyGeneticAlgorithm(arguments);

}

Future<void> startOnlyGeneticAlgorithm(List<String> args) async {

  String? fromCheckpoint;
  if (args.length == 1) {
    fromCheckpoint = args[0];
  }

  //fromCheckpoint = 'Gen-799';

  final GameRepository repository = GameRepository(
    gimmuCProvider: GimmuCProvider(),
    gimmuProvider: GimmuProvider(),
    gattacksProvider: GattacksProvider(),
    gunitsProvider: GunitsProvider(),
    tglobalProvider: TglobalProvider(),
    gtransfProvider: GtransfProvider(),
    gDynUpgrProvider: GDynUpgrProvider(),
  );
  repository.init();
  // Создание юнитов

  final List<Unit> units = List.generate(12, (index) => GameRepository.globalEmptyUnit);

  /*final List<String> unitNames = [
    'Рейнджер',
    'Жрец',
    'Рейнджер',
    'Сквайр',
    'Рыцарь',
    'Сквайр',

    'Орк',
    'Людоед',
    'Орк',
    'Русалка',
    '',
    '',
  ];*/

  final List<String> unitNames = UnitsPack.packs[0];

  assert(unitNames.length == 12);
  var index = 0;
  for (var name in unitNames) {
    units[index] = repository.getCopyUnitByName(name);
    index++;
  }

  final defaultAiFactory = NetworksFactory(
      unitLayers: [cellVectorLength, 128, 64, 32],
      layers: [32 * 12, 128, 64],
      cellsCount: cellsCount,
      cellVectorLength: cellVectorLength,
      input: cellVectorLength,
      output: actionsCount,
      networkVersion: 3);
  /*final individualAiFactory = NetworksFactory(
      unitLayers: [cellVectorLength, 128, 64, 32],
      layers: [32 * 12, 128, 64],
      cellsCount: cellsCount,
      cellVectorLength: cellVectorLength,
      input: cellVectorLength,
      output: actionsCount,
      networkVersion: 3);*/

  final individualAiFactory = NeatFactory(
      cellsCount: cellsCount,
      cellVectorLength: cellVectorLength,
      input: inputVectorLength,
      //input: 2,
      output: actionsCount,
      version: 1);

  final repo = GameRepository(
      gimmuCProvider: GimmuCProvider(),
      gimmuProvider: GimmuProvider(),
      gtransfProvider: GtransfProvider(),
      tglobalProvider: TglobalProvider(),
      gattacksProvider: GattacksProvider(),
      gDynUpgrProvider: GDynUpgrProvider(),
      gunitsProvider: GunitsProvider());

  final gc = GeneticController(
    gameController: GameController(
      attackController: AttackController(
        immuneController: ImmuneController(),
        gameRepository: repo,
        powerController: PowerController(
          randomExponentialDistribution: RandomExponentialDistribution(),
        ),
        damageScatter: DamageScatter(
          randomExponentialDistribution: RandomExponentialDistribution(),
        ),
        attackDurationController: AttackDurationController(),
      ),
      initiativeShuffler: InitiativeShuffler(
          randomExponentialDistribution: RandomExponentialDistribution()), gameRepository: repo,
    ),
    aiController: AiController(),
    updateStateContext: null,

    generationCount: 100000,
    maxIndividsCount: 200, // 20
    mutationsCount: 200, // 200
    crossesCount: 4,

    immutableIndividsCount: 5,
    geneticProcessesEvery: 5, // 10

    units: units.map((e) => e.copyWith()).toList(),
    individController: AiController(),
    fileProvider: DartFileProvider(),
    defaultAiFactory: defaultAiFactory,
    individualAiFactory: individualAiFactory,
  );

  // Инициализация с чекпоинта
  if (fromCheckpoint != null) {
    gc.initFromCheckpoint(fromCheckpoint);
  }

  print('Запуск алгоритма');
  await gc.startParallel(5, showBestBattle: false, safeEveryEpochs: 100); // 6
  print('Стоп алгоритма');
}
