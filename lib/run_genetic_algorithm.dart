import 'package:d2_ai_v2/ai_controller/ai_contoller.dart';
import 'package:d2_ai_v2/models/providers.dart';
import 'package:d2_ai_v2/providers/dart_file_provider.dart';
import 'package:d2_ai_v2/repositories/game_repository.dart';
import 'package:d2_ai_v2/utils/math_utils.dart';
import 'const.dart';
import 'controllers/attack_controller.dart';
import 'controllers/damage_scatter.dart';
import 'controllers/duration_controller.dart';
import 'controllers/game_controller.dart';
import 'controllers/initiative_shuffler.dart';
import 'controllers/power_controller.dart';
import 'models/unit.dart';
import 'optim_algorythm/genetic/genetic_controller.dart';

/*

Файл для запуска генетического алгоритма отдельно от всего приложения

*/


void main() async {
  await startOnlyGeneticAlgorithm();
}

Future<void> startOnlyGeneticAlgorithm() async {
  final GameRepository repository = GameRepository(
    gattacksProvider: GattacksProvider(),
    gunitsProvider: GunitsProvider(),
    tglobalProvider: TglobalProvider(),
  );
  repository.init();
  // Создание юнитов

  final List<Unit> units = List.generate(12, (index) => Unit.empty());

  final List<String> unitNames = [
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
  ];
  assert(unitNames.length == 12);
  var index = 0;
  for(var name in unitNames) {
    units[index] = repository.getCopyUnitByName(name);
    index++;
  }

  final gc = GeneticController(
    gameController: GameController(
      attackController: AttackController(
        powerController: PowerController(
          randomExponentialDistribution:
          RandomExponentialDistribution(),
        ),
        damageScatter: DamageScatter(
          randomExponentialDistribution:
          RandomExponentialDistribution(),
        ),
        attackDurationController: AttackDurationController(),
      ),
      initiativeShuffler: InitiativeShuffler(
          randomExponentialDistribution:
          RandomExponentialDistribution()),
    ),
    aiController: AiController(),
    updateStateContext: null,
    generationCount: 10000,
    maxIndividsCount: 20,
    input: neuralNetworkInputVectorLength,
    output: actionsCount,
    hidden: 2000,
    layers: 5,
    units: units.map((e) => e.copyWith()).toList(),
    individController: AiController(),
    fileProvider: DartFileProvider(),
    //fileProvider: FileProvider(),
  );

  // Инициализация с чекпоинта
  // /data/data/com.example.d2_ai_v2/app_flutter/2021-12-26 10:25:37.634445__Gen-39.json
  //gc.initFromCheckpoint('Gen-9');
  print('Запуск алгоритма');
  await gc.startParallel(10, showBestBattle: false, safeEveryEpochs: 100);
  print('Стоп алгоритма');
}