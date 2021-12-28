import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'package:d2_ai_v2/dart_nural/linear_network_v2.dart';
import 'package:d2_ai_v2/dart_nural/neural_base.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:d2_ai_v2/ai_controller/ai_contoller.dart';
import 'package:d2_ai_v2/controllers/attack_controller.dart';
import 'package:d2_ai_v2/controllers/damage_scatter.dart';
import 'package:d2_ai_v2/controllers/duration_controller.dart';
import 'package:d2_ai_v2/controllers/game_controller.dart';
import 'package:d2_ai_v2/controllers/initiative_shuffler.dart';
import 'package:d2_ai_v2/controllers/power_controller.dart';
import 'package:d2_ai_v2/models/unit.dart';

import 'package:collection/collection.dart';
import 'package:d2_ai_v2/optim_algorythm/genetic/genetic_checkpoint.dart';
import 'package:d2_ai_v2/providers/file_provider_base.dart';
import 'package:d2_ai_v2/update_state_context/update_state_context_base.dart';
import 'package:d2_ai_v2/utils/cell_utils.dart';
import 'package:d2_ai_v2/utils/math_utils.dart';
//import 'package:flutter/foundation.dart' show compute;

import 'individs/genetic_individ.dart';
import 'individs/genetic_individ_base.dart';

part 'genetic_controller.g.dart';

class GeneticController {
  /// Против какого ИИ будет обучаться текущий
  final AiController aiController;
  final AiController individController;
  final GameController gameController;
  final UpdateStateContextBase? updateStateContext;
  final FileProviderBase fileProvider;

  List<GeneticIndividBase> individs = [];

  /// Копии началных юнитов
  final List<Unit> unitsCopies = [];

  int generation = 0;

  int generationCount;
  int maxIndividsCount;
  bool inited = false;

  // Характеристики индивида
  int input;
  int output;

  List<int> layers;
  List<int> unitLayers;

  int cellsCount;
  int unitVectorLength;

  final random = Random();

  GeneticController({
    required this.gameController,
    required this.aiController,
    required this.updateStateContext,
    required this.generationCount,
    required this.maxIndividsCount,
    required this.input,
    required this.output,
    required this.layers,
    required this.unitLayers,
    required this.cellsCount,
    required this.unitVectorLength,
    required List<Unit> units,
    required this.individController,
    required this.fileProvider,
    bool initPopulation = true,
  }) {
    if (initPopulation) {
      for (var i = 0; i < maxIndividsCount; i++) {
        print('Создаётся индивид $i');
        final newIndivid = GeneticIndivid(
            input: input,
            output: output,
            layers: layers,
            unitLayers: unitLayers,
            cellsCount: cellsCount,
            unitVectorLength: unitVectorLength,
            initFrom: false,
            fitnessHistory: []);
        individs.add(newIndivid);
      }
      inited = true;
    }

    for (var u in units) {
      unitsCopies.add(u.copyWith());
    }
  }

  Future<void> initFromCheckpoint(String fileName) async {
    await fileProvider.init();
    print('Загрузка популяции из файла - $fileName');
    final jsonData = await fileProvider.getDataByFileName(fileName);
    GeneticAlgorithmCheckpoint checkpoint =
        GeneticAlgorithmCheckpoint.fromJson(jsonData);
    individs.clear();
    generation = checkpoint.currentGeneration + 1;
    int index = 0;
    print('Поколение - $generation');
    for (var ind in checkpoint.individs) {
      print('Индивид - $index. Приспособленность - ${ind.fitness}');
      individs.add(ind);
      index++;
    }

    input = checkpoint.input;
    output = checkpoint.output;
    layers = checkpoint.layers;
    unitLayers = checkpoint.unitLayers;
    cellsCount = checkpoint.cellsCount;
    unitVectorLength = checkpoint.unitVectorLength;

    inited = true;
  }

  static Future<_ParallelCalculatingResponse> calculateIndivids(
      _ParallelCalculatingRequest request) async {
    final firstUnits = request.units;
    final aiController = AiController();
    final individController = AiController();
    final gameController = GameController(
      attackController: AttackController(
        powerController: PowerController(
          randomExponentialDistribution: RandomExponentialDistribution(),
        ),
        damageScatter: DamageScatter(
          randomExponentialDistribution: RandomExponentialDistribution(),
        ),
        attackDurationController: AttackDurationController(),
      ),
      initiativeShuffler: InitiativeShuffler(
          randomExponentialDistribution: RandomExponentialDistribution()),
    );
    final neuralIndividIsTopTeam = request.neuralIsTopTeam;

    int indIndex = 0;

    final List<double> newFitness = [];
    final defaultNn = GeneticIndivid.fromJson(request.defaultNn).nn!;
    for (var ind
        in request.individs.map((e) => GeneticIndivid.fromJson(e)).toList()) {
      final units = List.generate(
          firstUnits.length, (index) => firstUnits[index].copyWith());

      aiController.init(units, nn: defaultNn);
      individController.init(units, nn: ind.nn!);

      gameController.init(units);
      final response = gameController.startGame();

      var currentActiveCellIndex = response.activeCell;

      var endGame = false;

      while (true) {
        if (gameController.currentRound > 100) {
          //ind.fitness = 0.0;
          //ind.needCalculate = false;
          break;
        }
        final isTopTeam = checkIsTopTeam(currentActiveCellIndex!);
        if (isTopTeam && neuralIndividIsTopTeam) {
          // Ходит индивид
          final actions = individController.getAction(currentActiveCellIndex);
          bool success = false;
          for (var a in actions) {
            final r = await gameController.makeAction(a);
            if (r.success) {
              success = true;
              currentActiveCellIndex = r.activeCell;
              endGame = r.endGame;
              break;
            }
          }
          assert(success);
          if (endGame) {
            break;
          }
        } else {
          // Ходит другой ИИ (в будущем может быть другой индивид)
          final actions = aiController.getAction(currentActiveCellIndex);
          bool success = false;
          for (var a in actions) {
            final r = await gameController.makeAction(a);
            if (r.success) {
              success = true;
              currentActiveCellIndex = r.activeCell;
              endGame = r.endGame;
              break;
            }
          }
          assert(success);

          if (endGame) {
            break;
          }
        }
      }
      // Подсчёт приспособленности
      // для начала это будет суммарное оставшееся ХП + число раундов
      final aisUnitsHp = <int>[];
      final aisUnitsMaxHp = <int>[];

      final enemyUnitsHp = <int>[];
      final enemyUnitsMaxHp = <int>[];

      int index = 0;
      for (var u in units) {
        if (checkIsTopTeam(index)) {
          // todo
          aisUnitsHp.add(u.currentHp);
          aisUnitsMaxHp.add(u.maxHp);
        } else {
          enemyUnitsHp.add(u.currentHp);
          enemyUnitsMaxHp.add(u.maxHp);
        }
        index++;
      }

      final hpFit = aisUnitsHp.sum / aisUnitsMaxHp.sum;
      final hpFitEnemy = 1 - enemyUnitsHp.sum / enemyUnitsMaxHp.sum;
      final rdFit = 100.0 / gameController.currentRound / 100;
      if (gameController.currentRound >= 100) {
        //ind.fitness = 0.0;
        newFitness.add(0.0);
      } else {
        //ind.fitness = hpFit + hpFitEnemy / 3.0; // + rdFit / 100.0;
        newFitness.add(hpFit + hpFitEnemy / 3.0);
      }
      gameController.reset();
    }

    //print('Кусок юнитов ${request.subListIndex} обработан');
    return _ParallelCalculatingResponse(
        index: request.subListIndex, fitness: newFitness);
  }

  /// Провести бой индивида и показать процесс боя в UI
  Future<void> startIndividBattle({
    required List<Unit> unitsCopies,
    required GeneticIndividBase ind,
    required AiController defaultController,
    required GameController gameController,
    required UpdateStateContextBase context,
    required bool individIsTopTeam,
    required GameNeuralNetworkBase defaultNn,
  }) async {
    print(
        'Проводится бой индивида. Его приспособленность - ${ind.getFitness()}');
    final units = List.generate(
        unitsCopies.length, (index) => unitsCopies[index].copyWith());

    final individPlayer = AiController();

    defaultController.init(units, nn: defaultNn);
    individPlayer.init(units, nn: ind.getNn());
    gameController.init(units);
    final response = gameController.startGame();
    var currentActiveCellIndex = response.activeCell;
    var endGame = false;

    while (true) {
      if (gameController.currentRound > 100) {
        break;
      }
      final isTopTeam = checkIsTopTeam(currentActiveCellIndex!);
      if (isTopTeam && individIsTopTeam) {
        // Ходит индивид
        final actions = individPlayer.getAction(currentActiveCellIndex);
        bool success = false;
        for (var a in actions) {
          a = a.copyWith(context: context);
          final r = await gameController.makeAction(a);
          if (r.success) {
            success = true;
            currentActiveCellIndex = r.activeCell;
            endGame = r.endGame;
            break;
          }
        }
        assert(success);
        if (endGame) {
          break;
        }
      } else {
        // Ходит другой ИИ (в будущем может быть другой индивид)
        final actions = defaultController.getAction(currentActiveCellIndex);
        bool success = false;
        for (var a in actions) {
          a = a.copyWith(context: context);
          final r = await gameController.makeAction(a);
          if (r.success) {
            success = true;
            currentActiveCellIndex = r.activeCell;
            endGame = r.endGame;
            break;
          }
        }
        assert(success);

        if (endGame) {
          break;
        }
      }
    }
    gameController.reset();
  }

  Future<void> startParallel(int isolatesCount,
      {bool showBestBattle = false, int safeEveryEpochs = 100}) async {
    const bool neuralIndividIsTopTeam = true;

    // Подгружается нейронка, которая будет управлять дефолтным контроллером
    /*await fileProvider.init();
    final checkPoint = GeneticAlgorithmCheckpoint.fromJson(
        await fileProvider.getDataByFileName('default_ai_controller'));
    final defaultIndivid = checkPoint.individs[0];*/

    for (generation; generation < generationCount; generation++) {
      print('Поколение - $generation');

      // Обновление в UI данных через контекст обновления
      /*updateStateContext?.emit(updateStateContext?.state.copyWith(
        currentGeneration: generation,
        populationFitness:
            List.generate(individs.length, (index) => individs[index].fitness)
                    .sum /
                individs.length,
      ));*/
      updateStateContext?.update(
        currentGeneration: generation,
        populationFitness: List.generate(
                individs.length, (index) => individs[index].getFitness()).sum /
            individs.length,
      );

      // Индивиды делятся на несколько частей по числу потоков
      final individsStep = individs.length ~/ isolatesCount;
      final individsStepRemainder = individs.length % isolatesCount;
      List<List<GeneticIndividBase>> individsPiece = [];
      int currentCaterPos = 0;
      for (var i = 0; i < isolatesCount; i++) {
        individsPiece.add(
            individs.sublist(currentCaterPos, currentCaterPos + individsStep));
        currentCaterPos += individsStep;
      }
      if (individsStepRemainder != 0) {
        individsPiece.add(individs.sublist(currentCaterPos));
      }
      assert(
          individsPiece.map((e) => e.length).toList().sum == individs.length);

      // Запуск изоляторов
      List<_ParallelCalculatingResponse> calcContext = [];

      for (var currentPiece = 0;
          currentPiece < individsPiece.length;
          currentPiece++) {
        // Копируем юнитов
        final unitCopies = List.generate(
            unitsCopies.length, (index) => unitsCopies[index].copyWith());

        /*await calculateIndivids(_ParallelCalculatingRequest(
          individs: individsPiece[currentPiece].map((e) => e.toJson()).toList(),
          //units: unitCopies.map((e) => e.toJson()).toList(),
          units: unitCopies,
          subListIndex: currentPiece,
          //gameController: gameController.copyWith(),
          neuralIsTopTeam: neuralIndividIsTopTeam,
          // todo Индивид пока создаётся случайный
          defaultNn: GeneticIndivid(
              input: input,
              output: output,
              layers: layers,
              unitLayers: unitLayers,
              cellsCount: cellsCount,
              unitVectorLength: unitVectorLength,
              initFrom: false,
              fitnessHistory: []).toJson(),
        )).then((value) {
          calcContext.add(value);
        });*/
        _startCalculateInBackground(_ParallelCalculatingRequest(
            individs: individsPiece[currentPiece].map((e) => e.toJson()).toList(),
            //units: unitCopies.map((e) => e.toJson()).toList(),
            units: unitCopies,
            subListIndex: currentPiece,
            //gameController: gameController.copyWith(),
            neuralIsTopTeam: neuralIndividIsTopTeam,
            defaultNn: GeneticIndivid(
                input: input,
                output: output,
                layers: layers,
                unitLayers: unitLayers,
                cellsCount: cellsCount,
                unitVectorLength: unitVectorLength,
                initFrom: false,
                fitnessHistory: []).toJson())).then((value) {
          calcContext.add(value);
          print('${(calcContext.length/individsPiece.length*100.0).toStringAsFixed(2)}%');
        });
        /*compute(
            calculateIndivids,
            _ParallelCalculatingRequest(
              individs:
                  individsPiece[currentPiece].map((e) => e.toJson()).toList(),
              //units: unitCopies.map((e) => e.toJson()).toList(),
              units: unitCopies,
              subListIndex: currentPiece,
              //gameController: gameController.copyWith(),
              neuralIsTopTeam: neuralIndividIsTopTeam,
              defaultNn: defaultIndivid.toJson(),
            )).then((value) {
          calcContext.add(value);
        });*/
      }

      // Ждём, когда все изоляторы отработают
      while (true) {
        if (calcContext.length == individsPiece.length) {
          break;
        }
        await Future.delayed(const Duration(milliseconds: 200));
        continue;
      }

      // Сортировка индивидов в порядке убывания индекса кусков
      calcContext.sort((a, b) => a.index.compareTo(b.index));

      // Обновление функций приспособленности
      // Нюанс тут в том, что ингдивид может делать правильные вещи
      // но иногда душат промахи. Для этого, что бы не терять сильного
      // индивида, смотрится не только текущее значение приспособленности,
      // но и несколько предыдущих. Берётся среднее
      int currentCaretPos = 0;
      for (var cc in calcContext) {
        for (var fit in cc.fitness) {
          print('Индивид - ${currentCaretPos}. '
              'History - ${individs[currentCaretPos].getFitnessHistory().map((e) => e.toStringAsFixed(2)).toList()} '
              'New fit - ${fit.toStringAsFixed(2)} '
              'Fitness - ${individs[currentCaretPos].getFitness().toStringAsFixed(2)}');
          //individs[currentCaretPos].fitness = fit;
          individs[currentCaretPos].getFitnessHistory().add(fit);
          currentCaretPos++;
        }
      }
      // Сохранение чекпоинта
      if ((generation + 1) % safeEveryEpochs == 0) {
        print('Сохранение чекпоинта...');
        _saveCheckpoint(generation);
        print('Сохранение чекпоинта успешно!');
      }
      // Генетические процесс происходят каждые n поколений
      if ((generation + 1) % 5 == 0) {
        // Показать в UI бой лучшего индивида, если нужно
        if (showBestBattle && updateStateContext != null) {
          await startIndividBattle(
              unitsCopies: List.generate(
                  unitsCopies.length, (index) => unitsCopies[index].copyWith()),
              ind: individs[0],
              defaultController: aiController,
              gameController: gameController,
              context: updateStateContext!,
              individIsTopTeam: true,
            defaultNn: LinearNeuralNetworkV2(
                input: input,
                output: output,
                layers: layers,
                unitLayers: unitLayers,
                initFrom: false,
                unitVectorLength: unitVectorLength,
                startWeights: null,
                startBiases: null,
                startActivations: null,
                unitStartWeights: null,
                unitStartBiases: null,
                unitStartActivations: null)
          );
        }
        print('Запуск генетических процессов ...');
        // Запуск основных генетических процессов
        _startGeneticProcess();
      }
    }
  }

  Future<_ParallelCalculatingResponse> _startCalculateInBackground(
      _ParallelCalculatingRequest request) async {
    int messageCounter = 0;
    final p = ReceivePort();
    // Главный ответ изолятора - список функций приспособленности
    _ParallelCalculatingResponse? response;
    final newIsolator =
        await Isolate.spawn(_startCalculatingIsolate, p.sendPort);
    p.listen((message) {
      // Первое сообщение от изолятора - это порт изолятора
      if (messageCounter == 0) {
        (message as SendPort).send(request);
        messageCounter++;
        return;
      }
      // Второе - это результат
      if (messageCounter == 1) {
        response = message as _ParallelCalculatingResponse;
      }
    });
    while (response == null) {
      await Future.delayed(const Duration(microseconds: 1));
    }
    newIsolator.kill(priority: Isolate.immediate);
    return response!;
  }

  static Future<void> _startCalculatingIsolate(SendPort p) async {
    final curRport = ReceivePort();
    _ParallelCalculatingResponse? response;
    p.send(curRport.sendPort);
    final requestData = (await curRport.first) as _ParallelCalculatingRequest;
    response = await calculateIndivids(requestData);
    p.send(response);
  }

  /*Future<_ParallelCalculatingResponse> _startCalculateInBackground(
      _ParallelCalculatingRequest request) async {
    int messageCounter = 0;
    final p = ReceivePort();
    // Главный ответ изолятора - список функций приспособленности
    _ParallelCalculatingResponse? response;
    final newIsolator = await Isolate.spawn(_startCalculatingIsolate, p.sendPort);
    p.listen((message) {
      // Первое сообщение от изолятора - это порт изолятора
      if (messageCounter == 0) {
        (message as SendPort).send(request.toJson());
        messageCounter++;
        return;
      }
      // Второе - это результат
      if (messageCounter == 1) {
        response = _ParallelCalculatingResponse.fromJson(message as Map<String, dynamic>);
      }
    });
    while(response == null) {
      await Future.delayed(const Duration(milliseconds: 1));
    }
    newIsolator.kill(priority: Isolate.immediate);
    return response!;
  }
  static Future<void> _startCalculatingIsolate(SendPort p) async {
    final curRport = ReceivePort();
    _ParallelCalculatingResponse? response;
    p.send(curRport.sendPort);
    final requestData = (await curRport.first) as Map<String, dynamic>;
    response = await calculateIndivids(
        _ParallelCalculatingRequest.fromJson(requestData));
    p.send(response.toJson());
  }*/

  /*Future<void> start({bool showUi = false}) async {
    print('Запуск алгоритма');
    if (!inited) {
      throw Exception();
    }
    for (var generation = 0; generation < generationCount; generation++) {
      print('Поколение - $generation');
      updateStateContext.emit(updateStateContext.state.copyWith(
        currentGeneration: generation,
        populationFitness:
            List.generate(individs.length, (index) => individs[index].fitness)
                    .sum /
                individs.length,
      ));

      const bool neuralIndividIsTopTeam = true;

      var curIndIndex = 0;
      for (var ind in individs) {
        print('Индивид $curIndIndex');

        if (ind.needCalculate || true) {
          final units = List.generate(
              unitsCopies.length, (index) => unitsCopies[index].copyWith());

          aiController.init(units);
          individController.init(units, nn: ind.nn);

          gameController.init(units);
          final response = gameController.startGame();

          var currentActiveCellIndex = response.activeCell;

          var endGame = false;

          while (true) {
            if (gameController.currentRound > 100) {
              ind.fitness = 0.0;
              ind.needCalculate = false;
              break;
            }

            final isTopTeam = checkIsTopTeam(currentActiveCellIndex!);

            if (isTopTeam && neuralIndividIsTopTeam) {
              // Ходит индивид
              final actions =
                  individController.getAction(currentActiveCellIndex);
              bool success = false;
              for (var a in actions) {
                if (showUi) {
                  a = a.copyWith(context: updateStateContext);
                }
                final r = await gameController.makeAction(a);
                if (r.success) {
                  success = true;
                  currentActiveCellIndex = r.activeCell;
                  endGame = r.endGame;
                  break;
                }
              }
              assert(success);

              if (endGame) {
                break;
              }
            } else {
              // Ходит другой ИИ (в будущем может быть другой индивид)
              final actions = aiController.getAction(currentActiveCellIndex);
              bool success = false;
              for (var a in actions) {
                if (showUi) {
                  a = a.copyWith(context: updateStateContext);
                }
                final r = await gameController.makeAction(a);
                if (r.success) {
                  success = true;
                  currentActiveCellIndex = r.activeCell;
                  endGame = r.endGame;
                  break;
                }
              }
              assert(success);

              if (endGame) {
                break;
              }
            }
          }

          ind.needCalculate = false;

          // Подсчёт приспособленности
          // для начала это будет суммарное оставшееся ХП + число раундов
          final aisUnitsHp = <int>[];
          final aisUnitsMaxHp = <int>[];

          final enemyUnitsHp = <int>[];
          final enemyUnitsMaxHp = <int>[];

          int index = 0;
          for (var u in units) {
            if (checkIsTopTeam(index)) {
              // todo
              aisUnitsHp.add(u.currentHp);
              aisUnitsMaxHp.add(u.maxHp);
            } else {
              enemyUnitsHp.add(u.currentHp);
              enemyUnitsMaxHp.add(u.maxHp);
            }
            index++;
          }

          final hpFit = aisUnitsHp.sum / aisUnitsMaxHp.sum;
          final hpFitEnemy = 1 - enemyUnitsHp.sum / enemyUnitsMaxHp.sum;

          final rdFit = 100.0 / gameController.currentRound / 100;
          print('Индивид $curIndIndex старая приспособленность ${ind.fitness}');
          if (gameController.currentRound >= 100) {
            ind.fitness = 0.0;
          } else {
            ind.fitness = hpFit + hpFitEnemy / 3.0; // + rdFit / 100.0;
          }
          print('Индивид $curIndIndex новая приспособленность ${ind.fitness}');
        }
        curIndIndex++;
        gameController.reset();
      }
      _startGeneticProcess();
      //_saveCheckpoint(generation);
    }
  }*/

  void _startGeneticProcess() {
    // Мутации кросс и обновление
    print('Селекция ...');
    _makeSelection();
    print('Мутации ...');
    for (var i = 0; i < individs.length ~/ 5; i++) {
      _mutateRandom();
    }
    print('Кросс ...');
    // Юниты отсортированы, делаем кросс лушчего
    //_crossUnitByIndex(bestIndex: 0, times: 1);
    //_crossUnitByIndex(bestIndex: 1, times: 2);
    for (var i = 0; i < individs.length ~/ 5; i++) {
      // print(i);
      final newInd = _cross();
      if (newInd != null) {
        individs.add(newInd);
      }
    }
  }

  void _sortIndivids() {
    // Теперь сортировка происходит немного хитрее
    // Приспособленность инживида равна среднему (потом можно сделать макс)
    // за несколько интераций. Таким образом сглаживается влияние промахов
    // и случайныхъ побед слабых индивидов
    individs.forEach((element) {
      final mean = element.getFitnessHistory().isNotEmpty
          ? element.getFitnessHistory().average
          : 0.0;
      print(
          'Individ old fit - ${element.getFitness().toStringAsFixed(2)} new fit - ${mean.toStringAsFixed(2)}');
      element.setFitness(mean);
      element.getFitnessHistory().clear();
    });

    individs.sort((a, b) => b.getFitness().compareTo(a.getFitness()));
  }

  void _makeSelection() {
    _sortIndivids();
    individs = individs.sublist(0, maxIndividsCount);
  }

  void _mutate(GeneticIndivid ind) {
    ind.mutate();
  }

  void _mutateRandom() {
    final randomIndex = random.nextInt(individs.length - 5) + 5;

    individs[randomIndex].mutate();
  }

  _crossUnitByIndex({int? times, required int bestIndex}) {
    int index = 0;
    while (index < (times ?? 1)) {
      final randomIndex1 = random.nextInt(individs.length);
      // Сам с собой не кроссится
      if (randomIndex1 == bestIndex) {
        continue;
      }
      individs.add(individs[bestIndex].cross(individs[randomIndex1]));
      index++;
    }
  }

  GeneticIndividBase? _cross() {
    final randomIndex1 = random.nextInt(individs.length);
    final randomIndex2 = random.nextInt(individs.length);

    if (randomIndex1 == randomIndex2) {
      print("Кросс не удался");
      return null;
    }

    final newInd = individs[randomIndex1].cross(individs[randomIndex2]);
    newInd.mutate();
    return newInd;
  }

  Future<void> _saveCheckpoint(int generation) async {
    final checkpoint = GeneticAlgorithmCheckpoint(
      individs: individs.map((e) => e as GeneticIndivid).toList(), // todo
      currentGeneration: generation,
      input: input,
      output: output,
      layers: layers,
      unitLayers: unitLayers,
      cellsCount: cellsCount,
      unitVectorLength: unitVectorLength,
    ).toJson();

    //var fileName = DateTime.now().toString() + '_Gen-$generation';
    var fileName = 'Gen-$generation';
    //fileName = 'checkpoint';
    print('Поколение для сохранения - $generation');
    print('Имя файла - $fileName');

    await fileProvider.init();
    await fileProvider.writeFile(fileName, checkpoint);
  }
}

@JsonSerializable()
class _ParallelCalculatingResponse {
  final int index;
  final List<double> fitness;

  _ParallelCalculatingResponse({required this.index, required this.fitness});

  factory _ParallelCalculatingResponse.fromJson(Map<String, dynamic> json) =>
      _$ParallelCalculatingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ParallelCalculatingResponseToJson(this);
}

@JsonSerializable()
class _ParallelCalculatingRequest {
  final List<Unit> units;
  final List<Map<String, dynamic>> individs;
  final Map<String, dynamic> defaultNn;
  final int subListIndex;
  final bool neuralIsTopTeam;

  _ParallelCalculatingRequest({
    required this.units,
    required this.individs,
    required this.subListIndex,
    required this.neuralIsTopTeam,
    required this.defaultNn,
  });

  factory _ParallelCalculatingRequest.fromJson(Map<String, dynamic> json) =>
      _$ParallelCalculatingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ParallelCalculatingRequestToJson(this);
}
