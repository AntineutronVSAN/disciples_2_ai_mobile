import 'dart:isolate';
import 'dart:math';

import 'package:d2_ai_v2/controllers/attack_controller/attack_controller.dart';
import 'package:d2_ai_v2/controllers/evaluation/evaluation_controller.dart';
import 'package:d2_ai_v2/controllers/game_controller/actions.dart';
import 'package:d2_ai_v2/controllers/game_controller/game_controller.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/utils/cell_utils.dart';

import 'ab_prunning_actions_order_controller.dart';


class ABPruningIsolate {

  static final actionsOrderController = ActionsOrderController(); // TODO DI
  static final evaluationController = EvaluationController(); // tood DI

  static int nodesCount = 0;

  static double maxPosEval = -double.infinity;

  Future<ABPruningBackgroundResponse> abPruningBackground({
    required GameController controllerSnapshot,
    required int treeDepth,
    required Function(double) onPosEval,
  }) async {

    nodesCount = 0;
    maxPosEval = -double.infinity;

    int messageCounter = 0;
    final p = ReceivePort();

    // Главный ответ изолятора
    ABPruningBackgroundResponse? response;

    final newIsolator = await Isolate.spawn(_startCalculatingIsolate, p.sendPort);
    p.listen((message) {
      // Первое сообщение от изолятора - это порт изолятора
      if (messageCounter == 0) {
        // Как получили порт отправляется запрос на рассчёт
        (message as SendPort).send(ABPruningBackgroundRequest(
            controllerSnapshot: controllerSnapshot,
            treeDepth: treeDepth));
        messageCounter++;
        return;
      }
      // Второе и более - это результат
      if (messageCounter > 0) {
        final mess = message as ABPruningBackgroundResponse;
        if (mess.isResult) {
          response = mess;
        } else {
          onPosEval(mess.currentPosRating);
        }
      }
    });
    while (response == null) {
      await Future.delayed(const Duration(microseconds: 1000));
    }
    p.close();
    newIsolator.kill(priority: Isolate.immediate);
    //newIsolator.kill();

    return response!;



  }

  static Future<void> _startCalculatingIsolate(SendPort p) async {
    final curRport = ReceivePort();

    //_ParallelCalculatingResponse? response;

    p.send(curRport.sendPort);

    // Первое сообщение от вызывающего изолятора - запрос на рассчёт
    final requestData = (await curRport.first) as ABPruningBackgroundRequest;

    var response = await _startCalculateABPruning(
        gameController: requestData.controllerSnapshot,
        treeDepth: requestData.treeDepth,
        /*onPosEval: (val) async {
          p.send(ABPruningBackgroundResponse(
              calculationMls: 0,
              nodesCount: nodesCount,
              resultActions: [],
              isResult: false,
              currentPosRating: val));
        }*/
    );

    p.send(response);

    curRport.close();
  }

  static Future<ABPruningBackgroundResponse> _startCalculateABPruning({
    required GameController gameController,
    required int treeDepth,
    //required Function(double) onPosEval,
  }) async {
    nodesCount = 0;
    Stopwatch s = Stopwatch();

    // Список всех возможных действий
    final allPossibleActions = actionsOrderController.getAllPossibleActions();

    // Текущий снапшот контроллера
    final currentSnapshot = gameController.getSnapshot();
    // После создания снапшота, у соперника (команда bot) ролл случайных параметров
    // выкручивается на максимум

    currentSnapshot.rollConfig.bottomTeamMaxIni = true;
    currentSnapshot.rollConfig.bottomTeamMaxPower = true;
    currentSnapshot.rollConfig.bottomTeamMaxDamage = true;

    currentSnapshot.rollConfig.topTeamMaxIni = false;
    currentSnapshot.rollConfig.topTeamMaxPower = true;
    currentSnapshot.rollConfig.topTeamMaxDamage = false;

    //currentSnapshot.rollMaxRandomParamsBotTeam = true;

    // Контекст обхода дерева
    final context = _ABPruningBypassContext(
        possibleActions: allPossibleActions, isTopTeam: true); //TODO

    // Первым дело нужно получить список возможных действий от копии контроллера
    List<RequestAction> currentPossibleActions = [];


    final orderedPossibleActions = actionsOrderController.getOrderActions(
        possibleActions: context.possibleActions,
        units: currentSnapshot.units,
        current: currentSnapshot.currentActiveCellIndex!);

    //for (var action in allPossibleActions) {
    for (var action in orderedPossibleActions) {
      // На всякий пожарный делается копия действия
      final a = action.deepCopy();
      final g = currentSnapshot.getSnapshot();
      final r = await g.makeAction(a);
      if (r.success) {
        currentPossibleActions.add(a);
      }
      if (r.endGame) {
        //final duration = s.elapsedMilliseconds;
        //print('Проанализировано $nodesCount узлов за $duration млс. ${nodesCount ~/ (duration / 1000.0)} узлов в секунду');
        s.stop();
        return ABPruningBackgroundResponse(
            isResult: true,
            currentPosRating: 0.0,
            calculationMls: 0,
            nodesCount: 0,
            resultActions: [a]);
        //return [a];
      }
    }

    var alpha = -double.infinity;
    var beta = double.infinity;

    final currentActiveUnitCellIndex = gameController.currentActiveCellIndex!;

    print('Ходит $currentActiveUnitCellIndex');

    final isMax = checkIsTopTeam(currentActiveUnitCellIndex);
    final isMin = !isMax;

    bool currentUnitAllTargets = currentSnapshot
        .units[currentActiveUnitCellIndex].unitAttack.targetsCount ==
        TargetsCount.all;
    bool currentUnitClicked = false;

    final _results = _ResultActions();

    s.start();
    if (isMax) {
      var maxEval = -double.infinity;
      int index = 0;
      for (var cpa in currentPossibleActions) {
        // Для юнитов со всеми целями не нужно считать каждый клик. Достаточно
        // одного
        if (currentUnitAllTargets &&
            currentUnitClicked &&
            cpa.type == ActionType.click) {
          index++;
          continue;
        }

        final res = await _bypass(
          //onPosEval: onPosEval,
          context: context,
          action: cpa,
          snapshot: currentSnapshot,
          //branchNumber: index,
          activeCellIndex: currentActiveUnitCellIndex,
          alpha: alpha,
          beta: beta,
          isMax: isMax, treeDepth: treeDepth,
        );
        print('Ход $index. Тип действия ${currentPossibleActions[index].type}, '
            'таргет ${currentPossibleActions[index].targetCellIndex}. Результат ${res.value}');

        // TODO Если понадобится отображать в UI текущую оценку позиции
        /*if (res.value > maxPosEval) {
          maxPosEval = res.value;
          onPosEval(res.value);
        }*/

        maxEval = max(res.value, maxEval);
        alpha = max(alpha, res.value);
        if (beta <= alpha) {
          break;
        }

        _results.actions.add(cpa.deepCopy());
        _results.results.add(res.value);

        if (cpa.type == ActionType.click) {
          if (currentUnitAllTargets) {
            if (!currentUnitClicked) {
              currentUnitClicked = true;
            }
          }
        }

        index++;
      }
    } else if (isMin) {
      throw Exception();
    } else {
      throw Exception();
    }

    int bestActionIndex = -1;
    double bestFit = -double.infinity;
    for (var i = 0; i < _results.actions.length; i++) {
      if (_results.results[i] == bestFit) {
        if (currentPossibleActions[i].type == ActionType.click) {
          bestFit = _results.results[i];
          bestActionIndex = i;
        }
      } else if (_results.results[i] > bestFit) {
        bestFit = _results.results[i];
        bestActionIndex = i;
      }
    }

    final duration = s.elapsedMilliseconds;
    print('Проанализировано $nodesCount узлов за $duration млс. ${nodesCount ~/ (duration / 1000.0)} узлов в секунду');
    s.stop();

    /*return [_results.actions[bestActionIndex].copyWith(
      positionRating: _results.results[bestActionIndex],
    )];*/

    return ABPruningBackgroundResponse(
      isResult: true,
      currentPosRating: 0.0,
      calculationMls: duration,
      nodesCount: nodesCount,
      resultActions: [_results.actions[bestActionIndex].copyWith(
        positionRating: _results.results[bestActionIndex]
      )]);
  }

  static Future<_ABPruningReturnValue> _bypass({
    required _ABPruningBypassContext context,
    required RequestAction action,
    required GameController snapshot,
    required int activeCellIndex,
    required double alpha,
    required double beta,
    required int treeDepth,
    //required Function(double) onPosEval,

    /// Является ли вызывающая нода функцией MAX
    required bool isMax,
  }) async {

    context.currentTreeDepth++;
    nodesCount++;

    final currentSnapshot = snapshot.getSnapshot();

    final res = await currentSnapshot.makeAction(action);

    if (!res.success) {
      throw Exception("Действие должно быть возможным. Неврные проверки на "
          "верхних уровнях, либо некорректная копия контроллера игры");
    }

    final maxValue = _calculateFitness(currentSnapshot.units);

    int newActiveCellIndex = res.activeCell!;

    final newIsMax = checkIsTopTeam(newActiveCellIndex);

    if (res.endGame || context.currentTreeDepth > treeDepth) {
      context.currentTreeDepth--;
      return _ABPruningReturnValue(value: maxValue);
    }

    bool currentUnitAllTargets = currentSnapshot
        .units[newActiveCellIndex]
        .unitAttack
        .targetsCount == TargetsCount.all;
    bool currentUnitClicked = false;

    List<RequestAction> currentPossibleActions = [];

    final orderedPossibleActions = actionsOrderController.getOrderActions(
        possibleActions: context.possibleActions,
        units: currentSnapshot.units,
        current: newActiveCellIndex);

    //for (var a in context.possibleActions) {
    for (var a in orderedPossibleActions) {

      final actionIsClick = a.type == ActionType.click;
      bool canMakeAction = true;
      // Перед тем, как скопировать контроллер и совершить над ним действие
      // (в идеале вообще не копировать его) через контроллер атак проверим
      // можно ли совершить данное действие
      if (actionIsClick) {
        canMakeAction = AttackController.unitCanClickTop(
            target: a.targetCellIndex!,
            current: newActiveCellIndex,
            units: currentSnapshot.units);
      }

      if (!canMakeAction) {
        //print('UNPOSSIBLE ACTION current $newActiveCellIndex target ${a.targetCellIndex!}');
        continue;
      }

      final g = currentSnapshot.getSnapshot();

      final r = await g.makeAction(a);

      if (r.success) {
        if (actionIsClick) {
          if (currentUnitAllTargets) {
            if (currentUnitClicked) {
              continue;
            } else {
              currentUnitClicked = true;
            }
          }

        }
        currentPossibleActions.add(a);
      }
    }
    if (currentPossibleActions.isEmpty) {
      context.currentTreeDepth--;
      return _ABPruningReturnValue(value: maxValue);
    }

    if (newIsMax) {
      var maxEval = -double.infinity;
      //assert(currentPossibleActions.isNotEmpty);
      for (var cpa in currentPossibleActions) {
        final res = await _bypass(
            //onPosEval: onPosEval,
            context: context,
            action: cpa,
            snapshot: currentSnapshot,
            activeCellIndex: newActiveCellIndex,
            alpha: alpha,
            beta: beta,
            isMax: newIsMax,
            treeDepth: treeDepth);

        maxEval = max(res.value, maxEval);
        alpha = max(alpha, res.value);
        if (beta <= alpha) {
          break;
        }
      }
      context.currentTreeDepth--;
      return _ABPruningReturnValue(value: maxEval);

    } else {
      var minEval = double.infinity;
      for (var cpa in currentPossibleActions) {
        final res = await _bypass(
            //onPosEval: onPosEval,
            context: context,
            action: cpa,
            snapshot: currentSnapshot,
            activeCellIndex: newActiveCellIndex,
            alpha: alpha,
            beta: beta,
            isMax: newIsMax,
            treeDepth: treeDepth);
        minEval = min(res.value, minEval);
        beta = min(beta, res.value);
        if (beta <= alpha) {
          break;
        }
      }
      context.currentTreeDepth--;
      return _ABPruningReturnValue(value: minEval);
    }

  }
  static double _calculateFitness(List<Unit> units) {
    var sfr = 0.0;
    double aiTeamEval = 0.0;
    double enemyTeamEval = 0.0;
    List<GameEvaluation> evaluations = [];
    var index=0;
    for (var u in units) {
      final newEval = GameEvaluation();
      if (checkIsTopTeam(index)) {
        // Свои
        //final currentUnitEval = evaluationController.getUnitEvaluation(u);
        //aiTeamEval += currentUnitEval.getEval();
        evaluationController.getUnitEvaluation(u, newEval);
        aiTeamEval += newEval.getEval();
      } else {
        // Враги
        //final currentUnitEval = evaluationController.getUnitEvaluation(u);
        //enemyTeamEval += currentUnitEval.getEval();
        evaluationController.getUnitEvaluation(u, newEval);
        enemyTeamEval += newEval.getEval();
      }
      evaluations.add(newEval);
      index++;
    }
    sfr += aiTeamEval;
    sfr -= enemyTeamEval;
    return sfr;
  }



}


/// Сообщение в изолятор
class ABPruningBackgroundRequest {
  final GameController controllerSnapshot;
  final int treeDepth;
  ABPruningBackgroundRequest({required this.controllerSnapshot, required this.treeDepth});
}

/// Ответ изолятора
class ABPruningBackgroundResponse {
  /// Число проанализированных нод
  final int nodesCount;
  /// Сколько времени в млс потрачено на рассчёт
  final int calculationMls;

  final bool isResult;
  final double currentPosRating;

  final List<RequestAction> resultActions;

  ABPruningBackgroundResponse({
    required this.calculationMls,
    required this.nodesCount,
    required this.resultActions,
    required this.isResult,
    required this.currentPosRating,
  });

}



/// Контекст обхода дерева при альфа-бета отсечении
class _ABPruningBypassContext {
  /// Все возможные действия
  List<RequestAction> possibleActions;

  /// ИИ оценивает ситуацию за тополвую команду
  final bool isTopTeam;

  int bestFitnessBranchNumber = -1;

  int currentTreeDepth = 0;

  int currentRecLevel = 0;

  /// Лучгий изученный вариант ИИ
  double alpha = 0.0;

  /// Лучший изученный вариант Enemy
  double beta = 0.0;

  _ABPruningBypassContext(
      {required this.possibleActions, required this.isTopTeam});

  void addRec() {
    currentRecLevel++;
    if (currentRecLevel > 10000000) {
      throw Exception();
    }
  }
}

class _ABPruningReturnValue {
  double? alpha;
  double? beta;
  double value;

  _ABPruningReturnValue({required this.value});
}

class _ResultActions {
  final List<double> results = [];
  final List<RequestAction> actions = [];
}