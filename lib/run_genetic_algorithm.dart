import 'package:collection/src/iterable_extensions.dart';
import 'package:d2_ai_v2/ai_controller/ai_contoller.dart';
import 'package:d2_ai_v2/dart_nural/linear_network_v2.dart';
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
import 'dart_nural/multilayer_perceptron.dart';
import 'models/unit.dart';
import 'optim_algorythm/genetic/genetic_controller.dart';

/*

Файл для запуска генетического алгоритма отдельно от всего приложения

*/


void main(List<String> arguments) async {
  await startOnlyGeneticAlgorithm(arguments);

  /*final nn = MultilayerPerceptron(
      input: 37,
      output: 100,
      layers: [128, 256, 256],
      initFrom: false,
      startWeights: null,
      startBiases: null,
      startActivations: null);

  final result = nn.forward(List.generate(37, (index) => nn.getRandomValue()));*/

  /*final nn = LinearNeuralNetworkV2(
      input: 37,
      output: 100,
      layers: [128, 256, 256],
      unitLayers: [37, 128, 256, 128],
      initFrom: false,
      unitVectorLength: 37,
      startWeights: null,
      startBiases: null,
      startActivations: null,
      unitStartWeights: null,
      unitStartBiases: null,
      unitStartActivations: null);

  final result = nn.forward(List.generate(37*12, (index) => nn.getRandomValue()));*/

}

Future<void> startOnlyGeneticAlgorithm(List<String> args) async {
  String? fromCheckpoint;
  if (args.length == 1) {
    fromCheckpoint = args[0];
  }
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
    generationCount: 100000,
    maxIndividsCount: 40,
    input: cellVectorLength,
    output: actionsCount,
    units: units.map((e) => e.copyWith()).toList(),
    individController: AiController(),
    fileProvider: DartFileProvider(),
    layers: [32, 64, 128, 64],
    unitVectorLength: cellVectorLength,
    unitLayers: [cellVectorLength, 128, 32],
    cellsCount: 12,
    //fileProvider: FileProvider(),
  );

  // Инициализация с чекпоинта
  // /data/data/com.example.d2_ai_v2/app_flutter/2021-12-26 10:25:37.634445__Gen-39.json
  if (fromCheckpoint != null) {
    gc.initFromCheckpoint(fromCheckpoint);
  }

  print('Запуск алгоритма');
  await gc.startParallel(5, showBestBattle: false, safeEveryEpochs: 100);
  print('Стоп алгоритма');
}