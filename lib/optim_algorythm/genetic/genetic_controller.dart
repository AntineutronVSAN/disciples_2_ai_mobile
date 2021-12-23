import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:d2_ai_v2/ai_controller/ai_contoller.dart';
import 'package:d2_ai_v2/bloc/bloc.dart';
import 'package:d2_ai_v2/controllers/attack_controller.dart';
import 'package:d2_ai_v2/controllers/damage_scatter.dart';
import 'package:d2_ai_v2/controllers/duration_controller.dart';
import 'package:d2_ai_v2/controllers/game_controller.dart';
import 'package:d2_ai_v2/controllers/initiative_shuffler.dart';
import 'package:d2_ai_v2/controllers/power_controller.dart';
import 'package:d2_ai_v2/models/unit.dart';

import 'package:collection/collection.dart';
import 'package:d2_ai_v2/utils/cell_utils.dart';
import 'package:d2_ai_v2/utils/math_utils.dart';
import 'package:flutter/foundation.dart';

import 'genetic_individ.dart';
import 'genetic_worker.dart';

class GeneticController {
  /// Против какого ИИ будет обучаться текущий
  final AiController aiController;
  final AiController individController;
  final GameController gameController;
  final UpdateStateContext updateStateContext;

  List<GeneticIndivid> individs = [];

  /// Копии началных юнитов
  final List<Unit> unitsCopies = [];

  int generation = 0;

  int generationCount;
  int maxIndividsCount;
  bool inited = false;

  // Характеристики индивида
  final int input;
  final int output;
  final int hidden;
  final int layers;

  final random = Random();

  GeneticController({
    required this.gameController,
    required this.aiController,
    required this.updateStateContext,
    required this.generationCount,
    required this.maxIndividsCount,
    required this.input,
    required this.output,
    required this.hidden,
    required this.layers,
    required List<Unit> units,
    required this.individController,
  }) {
    for (var i = 0; i < maxIndividsCount; i++) {
      print('Создаётся индивид $i');
      final newIndivid = GeneticIndivid(
        input: input,
        output: output,
        hidden: hidden,
        layers: layers,
      );
      individs.add(newIndivid);
    }

    for (var u in units) {
      unitsCopies.add(u.copyWith());
    }
    inited = true;
  }

  static Future<_ParallelCalculatingResponse> calculateIndivids(
      _ParallelCalculatingRequest request) async {
    //final units = request.units.map((e) => Unit.fromJson(e)).toList();
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

    for (var ind
        in request.individs.map((e) => GeneticIndivid.fromJson(e)).toList()) {
      print('Подлист - ${request.subListIndex} индивид $indIndex');

      final units = List.generate(
          firstUnits.length, (index) => firstUnits[index].copyWith());

      aiController.init(units);
      individController.init(units, nn: ind.nn);

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

    print('Кусок юнитов ${request.subListIndex} обработан');
    return _ParallelCalculatingResponse(
        index: request.subListIndex, fitness: newFitness);
  }

  Future<void> startParallel(int isolatesCount) async {
    const bool neuralIndividIsTopTeam = true;
    for (var generation = 0; generation < generationCount; generation++) {
      print('Поколение - $generation');
      updateStateContext.emit(updateStateContext.state.copyWith(
        currentGeneration: generation,
        populationFitness:
            List.generate(individs.length, (index) => individs[index].fitness)
                    .sum /
                individs.length,
      ));

      // Индивиды делятся на несколько частей по числу потоков
      final individsStep = individs.length ~/ isolatesCount;
      final individsStepRemainder = individs.length % isolatesCount;

      List<List<GeneticIndivid>> individsPiece = [];

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

      // По списку видим, что рассчёт индивидов остановлен
      //final insolateCoplete = List.generate(individsPiece.length, (index) => false);

      List<_ParallelCalculatingResponse> calcContext = [];

      for (var currentPiece = 0;
          currentPiece < individsPiece.length;
          currentPiece++) {
        // Копируем юнитов
        final unitCopies = List.generate(
            unitsCopies.length, (index) => unitsCopies[index].copyWith());
        // Запускаем
        compute(
            calculateIndivids,
            _ParallelCalculatingRequest(
              individs:
                  individsPiece[currentPiece].map((e) => e.toJson()).toList(),
              //units: unitCopies.map((e) => e.toJson()).toList(),
              units: unitCopies,
              subListIndex: currentPiece,
              //gameController: gameController.copyWith(),
              neuralIsTopTeam: neuralIndividIsTopTeam,
            )).then((value) {
          calcContext.add(value);
        });
      }

      while (true) {
        if (calcContext.length == individsPiece.length) {
          break;
        }
        await Future.delayed(const Duration(milliseconds: 200));
        continue;
      }

      // Сортировка индивидов в порядке убывания индекса кусков
      calcContext.sort((a, b) => a.index.compareTo(b.index));

      int currentCaretPos = 0;
      for (var cc in calcContext) {
        for (var fit in cc.fitness) {
          print('Индивид - ${currentCaretPos}. '
              'Old fit - ${individs[currentCaretPos].fitness} '
              'New fit - ${fit}');
          individs[currentCaretPos].fitness = fit;
          currentCaretPos++;
        }
      }

      // Мутации кросс и обновление
      print('Селекция ...');
      _makeSelection();
      print('Мутации ...');
      for (var i = 0; i < 5; i++) {
        print(i);
        _mutateRandom();
      }
      print('Кросс ...');
      for (var i = 0; i < 5; i++) {
        print(i);
        _cross();
      }
    }

    /*for(var i=0; i<isolatesCount; i++) {
      final sum = compute(_set, i).then((value) {
        insolateCoplete[value] = true;
      });
    }

    print('Засыпаем');
    while (true) {
      if (insolateCoplete.any((element) => !element)) {
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }
      break;
    }
    print('Просыпаемся');*/
    // Освобождение ресурсов!
    /*for (var isolate in isolates) {
      isolate.kill(priority: Isolate.immediate);
    }*/
  }

  Future<void> start({bool showUi = false}) async {
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

      // Мутации кросс и обновление
      //print('Селекция ...');
      _makeSelection();
      //print('Мутации ...');
      for (var i = 0; i < 10; i++) {
       // print(i);
        _mutateRandom();
      }
      //print('Кросс ...');
      for (var i = 0; i < 10; i++) {
       // print(i);
        _cross();
      }
    }
  }

  void _sortIndivids() {
    individs.sort((a, b) => b.fitness.compareTo(a.fitness));
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

  GeneticIndivid _cross() {
    final randomIndex1 = random.nextInt(individs.length);
    final randomIndex2 = random.nextInt(individs.length);
    final newInd = individs[randomIndex1].cross(individs[randomIndex2]);
    newInd.mutate();
    return newInd;
  }
}

class _ParallelCalculatingResponse {
  final int index;
  final List<double> fitness;

  _ParallelCalculatingResponse({required this.index, required this.fitness});
}

class _ParallelCalculatingRequest {
  final List<Unit> units;
  final List<Map<String, dynamic>> individs;
  final int subListIndex;
  final bool neuralIsTopTeam;

  _ParallelCalculatingRequest({
    required this.units,
    required this.individs,
    required this.subListIndex,
    required this.neuralIsTopTeam,
  });
}
