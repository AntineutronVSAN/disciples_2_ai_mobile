import 'dart:math';

import 'package:collection/src/iterable_extensions.dart';
import 'package:d2_ai_v2/ai_controller/ai_controller_base.dart';
import 'package:d2_ai_v2/controllers/attack_controller/attack_controller.dart';
import 'package:d2_ai_v2/controllers/evaluation/evaluation_controller.dart';
import 'package:d2_ai_v2/controllers/game_controller/actions.dart';
import 'package:d2_ai_v2/controllers/game_controller/game_controller.dart';
import 'package:d2_ai_v2/controllers/game_controller/sync_game_controller.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/optim_algorythm/base.dart';
import 'package:d2_ai_v2/optim_algorythm/individual_base.dart';
import 'package:d2_ai_v2/providers/file_provider_base.dart';
import 'package:d2_ai_v2/update_state_context/update_state_context_base.dart';
import 'package:d2_ai_v2/utils/cell_utils.dart';

import 'ab_pruning_isolate.dart';
import 'ab_prunning_actions_order_controller.dart';

const double globalMaxValue = double.infinity;
const double globalMinValue = -double.infinity;

/// Класс реализующий алгоритм альфа-бета отсечения
class AlphaBetaPruningController extends AiControllerBase {
  final ABPruningIsolate abPruningIsolate = ABPruningIsolate();

  /// Глубина рассчёта в ходах (не в раундах)
  int treeDepth;

  /// ИИ играет за верхнюю команду?
  final bool isTopTeam;

  AlphaBetaPruningController(
      {required this.treeDepth, required this.isTopTeam});

  @override
  Future<List<RequestAction>> getAction(int currentActiveUnitCellIndex,
      {GameController? gameController,
      UpdateStateContextBase? updateStateContext}) async {
    final result = await abPruningIsolate.abPruningBackground(
        controllerSnapshot: gameController!.getSnapshot(),
        treeDepth: treeDepth,
        onPosEval: (val) async {
          if (updateStateContext != null) {
            await updateStateContext.update(posRating: val);
          }
        },
        onNodesPerSecond: (val) async {
          if (updateStateContext != null) {
            await updateStateContext.update(nodesPerSecond: val);
          }
        });

    return result.resultActions;
  }

  @override
  void init(List<Unit> units, {required AiAlgorithm algorithm}) {
    // TODO: implement init
  }

  @override
  Future<void> initFromFile(List<Unit> units, String filePath,
      FileProviderBase fileProvider, IndividualFactoryBase factory,
      {int individIndex = 0}) {
    // TODO: implement initFromFile
    throw UnimplementedError();
  }

  @override
  void initFromIndivid(List<Unit> units, IndividualBase ind) {
    // TODO: implement initFromIndivid
  }
}

/*

class AlphaBetaPruningControllerDeprecated extends AiControllerBase {

  /// Глубина рассчёта в ходах (не в раундах)
  int treeDepth;

  /// ИИ играет за верхнюю команду?
  final bool isTopTeam;

  final actionsOrderController = ActionsOrderController(); // TODO DI

  AlphaBetaPruningControllerDeprecated(
      {required this.treeDepth, required this.isTopTeam});

  /// Кеш нод
  //final Map<String, _ABPruningReturnValue> _nodesCache = {};

  /// Сколько нод проанализировано
  int nodesCount = 0;

  /// Стопватч для анализа обходов
  final Stopwatch bypassStopWatch = Stopwatch();
  /// Суммарное время млс, потраченное на копирование действия
  int timeCopyAction = 0;
  /// Суммарное время млс, потраченное на копирование контроллера
  int timeCopyController = 0;
  /// Суммарное время млс, потраченное на действие
  int timeAction = 0;
  /// Суммарное время потраченное на рассчёт fintess
  int timeFitness = 0;

  /// Контроллер для оценки позиции
  EvaluationController evaluationController = EvaluationController(); // tood DI

  /// Порог значения для выбора действия защиты или атаки
  /// Например, если [protectClickMinValue] = 1
  /// СФО при защите = 5.1
  /// СФО при атаке =  5.01
  /// Выберется действие атаки, т.к. 5.1 - 5.01 < [protectClickMinValue]
  static const double protectClickMinValue = 1.0;


  @override
  Future<List<RequestAction>> getAction(int currentActiveUnitCellIndex,
      {GameController? gameController}) async {
    assert(gameController != null);
    nodesCount = 0;
    //_nodesCache.clear();

    timeCopyAction = 0;
    timeCopyController = 0;
    timeAction = 0;
    timeFitness = 0;

    // todo Дать врагам AI максимальный бонус к ини
    // todo Дать врагам AI максимальный бонус к урону
    // todo Подумать как можно адекватно учитывать точность
    // todo Подумать как улучшить функцию оценки

    // Список всех возможных действий
    final allPossibleActions = actionsOrderController.getAllPossibleActions();

    // Текущий снапшот контроллера
    final currentSnapshot = gameController!.getSnapshot();
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
        possibleActions: allPossibleActions, isTopTeam: isTopTeam);

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
        return [a];
      }
    }

    var alpha = -double.infinity;
    var beta = double.infinity;

    print('Ходит $currentActiveUnitCellIndex');

    final isMax = checkIsTopTeam(currentActiveUnitCellIndex);
    final isMin = !isMax;

    bool currentUnitAllTargets = currentSnapshot
        .units[currentActiveUnitCellIndex].unitAttack.targetsCount ==
        TargetsCount.all;
    bool currentUnitClicked = false;

    final _results = _ResultActions();

    Stopwatch s = Stopwatch();
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
          context: context,
          action: cpa,
          snapshot: currentSnapshot,
          //branchNumber: index,
          activeCellIndex: currentActiveUnitCellIndex,
          alpha: alpha,
          beta: beta,
          isMax: isMax,
        );
        print('Ход $index. Тип действия ${currentPossibleActions[index].type}, '
            'таргет ${currentPossibleActions[index].targetCellIndex}. Результат ${res.value}');

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

    return [_results.actions[bestActionIndex].copyWith(
      positionRating: _results.results[bestActionIndex],
    )];
  }

  Future<_ABPruningReturnValue> _bypass({
    required _ABPruningBypassContext context,
    required RequestAction action,
    required GameController snapshot,
    required int activeCellIndex,
    required double alpha,
    required double beta,

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
            context: context,
            action: cpa,
            snapshot: currentSnapshot,
            activeCellIndex: newActiveCellIndex,
            alpha: alpha,
            beta: beta,
            isMax: newIsMax);

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
            context: context,
            action: cpa,
            snapshot: currentSnapshot,
            activeCellIndex: newActiveCellIndex,
            alpha: alpha,
            beta: beta,
            isMax: newIsMax);
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

  double _calculateFitness(List<Unit> units) {

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




  @override
  void init(List<Unit> units, {required AiAlgorithm algorithm}) {
    throw Exception();
  }

  @override
  Future<void> initFromFile(List<Unit> units, String filePath,
      FileProviderBase fileProvider, IndividualFactoryBase factory,
      {int individIndex = 0}) async {
    throw Exception();
  }

  @override
  void initFromIndivid(List<Unit> units, IndividualBase ind) {
    throw Exception();
  }
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

*/
