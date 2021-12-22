import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:d2_ai_v2/ai_controller/ai_contoller.dart';
import 'package:d2_ai_v2/bloc/bloc.dart';
import 'package:d2_ai_v2/controllers/game_controller.dart';
import 'package:d2_ai_v2/models/unit.dart';

import 'package:collection/collection.dart';
import 'package:d2_ai_v2/utils/cell_utils.dart';

import 'genetic_individ.dart';

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
  bool inited=false;

  // Характеристики индивида
  final int input;
  final int output;
  final int hidden;
  final int layers;

  final random = Random();

  GeneticController(
      {required this.gameController,
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
    for(var i=0; i<maxIndividsCount; i++) {
      print('Создаётся индивид $i');
      final newIndivid = GeneticIndivid(
        input: input,
        output: output,
        hidden: hidden,
        layers: layers,
      );
      individs.add(newIndivid);
    }

    for(var u in units) {
      unitsCopies.add(u.copyWith());
    }
    inited = true;
  }

  Future<void> startParallel(int isolatesCount) async {

    List<Isolate> isolates = [];

    List<ReceivePort> ports = List.generate(isolatesCount, (index) => ReceivePort());

    for(var p in ports) {
      isolates.add(await Isolate.spawn(gfg, p.sendPort));
    }

    // Извлечение нового порта для общения
    //newIsolateSendPort = await receivePort.first;

    await Future.delayed(const Duration(seconds: 100000));

  }
  static void gfg(SendPort sendPort) {

    // Инстанцирует отправляющий порт для приема сообщения
    ReceivePort newIsolateReceivePort = ReceivePort();
    // Предоставляет ссылку на SandPort новых Изолятов
    sendPort.send(newIsolateReceivePort.sendPort);


    int counter = 0;

    Timer.periodic(new Duration(seconds: 1), (Timer t) {
      counter++;
      print(counter);
    });
  }



  Future<void> start({bool showUi = false}) async {
    print('Запуск алгоритма');
    if (!inited) {
      throw Exception();
    }

    for(var generation=0; generation<generationCount; generation++) {
      print('Поколение - $generation');
      updateStateContext.emit(updateStateContext.state.copyWith(
        currentGeneration: generation,
        populationFitness: List.generate(individs.length, (index) => individs[index].fitness).sum / individs.length,
      ));

      const bool neuralIndividIsTopTeam = true;

      var curIndIndex = 0;
      for(var ind in individs) {
        print('Индивид $curIndIndex');

        if (ind.needCalculate || true) {
          final units = List.generate(unitsCopies.length, (index) => unitsCopies[index].copyWith());

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
              final actions = individController.getAction(currentActiveCellIndex);
              bool success = false;
              for(var a in actions) {
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
              for(var a in actions) {
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

          int index=0;
          for(var u in units) {
            if (checkIsTopTeam(index)) { // todo
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
      print('Селекция ...');
      _makeSelection();
      print('Мутации ...');
      for(var i=0; i<5; i++){
        print(i);
        _mutateRandom();
      }
      print('Кросс ...');
      for(var i=0; i<5; i++){
        print(i);
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
    final randomIndex = random.nextInt(individs.length);
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





