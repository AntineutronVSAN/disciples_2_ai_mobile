import 'dart:math';

import 'package:collection/src/iterable_extensions.dart';
import 'package:d2_ai_v2/ai_controller/ai_controller_base.dart';
import 'package:d2_ai_v2/controllers/game_controller/actions.dart';
import 'package:d2_ai_v2/controllers/game_controller/game_controller.dart';
import 'package:d2_ai_v2/controllers/game_controller/sync_game_controller.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/optim_algorythm/base.dart';
import 'package:d2_ai_v2/optim_algorythm/individual_base.dart';
import 'package:d2_ai_v2/providers/file_provider_base.dart';
import 'package:d2_ai_v2/utils/cell_utils.dart';

/// Класс реализующий алгоритм альфа-бета отсечения
/// ИИ стремится максимльно раздамажить отряд
/// Противник стремится также раздамажить отряд
class AlphaBetaPruningController extends AiControllerBase {
  /// Глубина рассчёта в ходах (не в раундах)
  int treeDepth;

  /// ИИ играет за верхнюю команду?
  final bool isTopTeam;

  AlphaBetaPruningController(
      {required this.treeDepth, required this.isTopTeam});

  @override
  Future<List<RequestAction>> getAction(int currentActiveUnitCellIndex,
      {GameController? gameController}) async {
    assert(gameController != null);

    // Список всех возможных действий
    List<RequestAction> allPossibleActions = [
      ...List.generate(12, (index) {
        return RequestAction(
            type: ActionType.click,
            targetCellIndex: index,
            currentCellIndex: null);
      }),
      RequestAction(
          type: ActionType.protect,
          targetCellIndex: null,
          currentCellIndex: null),
      RequestAction(
          type: ActionType.wait, targetCellIndex: null, currentCellIndex: null),


    ];

    // Текущий снапшот контролера
    final currentSnapshot = gameController!.getSnapshot();

    // Контекст обхода дерева
    final context = _ABPruningBypassContext(
        possibleActions: allPossibleActions, isTopTeam: isTopTeam);

    // Первым дело нужно получить список возможных действий от копии контроллера
    List<RequestAction> currentPossibleActions = [];

    for (var action in allPossibleActions) {
      // На всякий пожарный делается копия действия
      final a = action.deepCopy();
      final g = currentSnapshot.getSnapshot();
      final r = g.makeAction(a);
      if (r.success) {
        currentPossibleActions.add(a);
      }
      if (r.endGame) {
        return [a];
      }
    }


    var alpha = -double.infinity;
    var beta = double.infinity;

    //double bestResult = -double.infinity;
    int bestResultActionIndex = -1;

    print('Ходит $currentActiveUnitCellIndex');

    final isMax = checkIsTopTeam(currentActiveUnitCellIndex);
    final isMin = !isMax;

    if (isMax) {
      var maxEval = -double.infinity;
      int index = 0;
      for (var cpa in currentPossibleActions) {
        final res = _bypass(
            context: context,
            action: cpa,
            snapshot: currentSnapshot,
            //branchNumber: index,
            activeCellIndex: currentActiveUnitCellIndex,
            alpha: alpha,
            beta: beta
        );
        print('Ход $index. Тип действия ${currentPossibleActions[index].type}, '
            'таргет ${currentPossibleActions[index].targetCellIndex}. Результат ${res.value}');
        assert(context.currentTreeDepth == 0);
        if (res.value >= maxEval) {
          bestResultActionIndex = index;
        }
        maxEval = max(res.value, maxEval);
        alpha = max(alpha, res.value);
        if (beta <= alpha) {
          break;
        }

        index++;
      }
    } else if (isMin) {
      throw Exception();
      int index = 0;
      var minEval = double.infinity;
      for (var cpa in currentPossibleActions) {
        final res = await _bypass(
            context: context,
            action: cpa,
            snapshot: currentSnapshot,
            //branchNumber: index,
            activeCellIndex: currentActiveUnitCellIndex,
            alpha: alpha,
            beta: beta
        );
        print('Ход $index. Тип действия ${currentPossibleActions[index].type}, '
            'таргет ${currentPossibleActions[index].targetCellIndex}. Результат ${res.value}');
        assert(context.currentTreeDepth == 0);
        if (res.value <= minEval) {
          bestResultActionIndex = index;
        }
        minEval = min(res.value, minEval);
        beta = min(beta, res.value);
        if (beta <= alpha) {
          break;
        }
        index++;
      }
    } else {
      throw Exception();
    }



    //final int bestFitnessBranch = context.bestFitnessBranchNumber;

    return [currentPossibleActions[bestResultActionIndex]];
  }



  var test = <int>[];

  /// Рекурсивный обход вариантов. [branchNumber] номер ветви первоначального действия
  _ABPruningReturnValue _bypass(
      {required _ABPruningBypassContext context,
        required RequestAction action,
        required SyncGameController snapshot,
        //required int branchNumber,
        required int activeCellIndex,
        required double alpha,
        required double beta,
      }) {
    context.addRec();
    context.currentTreeDepth++;

    /*final isMax = checkIsTopTeam(activeCellIndex);
    final isMin = !isMax;*/

    final currentSnapshot = snapshot.getSnapshot();
    final res = currentSnapshot.makeAction(action);
    if (!res.success) {
      throw Exception("Действие должно быть возможным. Неврные проверки на "
          "верхних уровнях, либо некорректная копия контроллера игры");
    }

    /// Данное значение должен максимизировать MAX
    final maxValue = _calculateFitness(currentSnapshot.units);
    /// Данное значение должен минимизировать MIN
    final minValue = _enemyFitness(currentSnapshot.units);

    /*if (res.endGame || context.currentTreeDepth > treeDepth) {
      context.currentTreeDepth--;
      if (isMax) {
        return _ABPruningReturnValue(value: maxValue);
      } else if (isMin) {
        return _ABPruningReturnValue(value: minValue);
      } else {
        throw Exception();
      }
    }*/

    int newActiveCellIndex = res.activeCell!;
    final isMax = checkIsTopTeam(newActiveCellIndex);
    final isMin = !isMax;

    if (res.endGame || context.currentTreeDepth > treeDepth) {
      context.currentTreeDepth--;
      if (isMax) {
        return _ABPruningReturnValue(value: maxValue);
      } else if (isMin) {
        return _ABPruningReturnValue(value: minValue);
      } else {
        throw Exception();
      }
    }

    // Следующий список возможных действий
    // TODO У юнита, который бьёт по всем не обязательно рассматривать
    // клик на каждого юнита. Достаточно только за одного

    bool currentUnitAllTargets = currentSnapshot
        .units[newActiveCellIndex]
        .unitAttack
        .targetsCount == TargetsCount.all;
    bool currentUnitClicked = false;

    List<RequestAction> currentPossibleActions = [];
    for (var defaultAction in context.possibleActions) {
      // На всякий пожарный делается копия действия
      final a = defaultAction.deepCopy();
      final g = currentSnapshot.getSnapshot();
      final r = g.makeAction(a);
      if (r.success) {
        if (a.type == ActionType.click) {

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
      if (isMax) {
        return _ABPruningReturnValue(value: maxValue);
      } else if (isMin) {
        return _ABPruningReturnValue(value: minValue);
      } else {
        throw Exception();
      }
    }

    assert(currentPossibleActions.length < context.possibleActions.length);
    /*if (!(currentPossibleActions.length < context.possibleActions.length)) {
      print('');
    }*/
    //print(currentPossibleActions.length);
    /*double currentVal;

    if (isMax) {
      currentVal = -double.infinity;
    } else if (isMin) {
      currentVal = double.infinity;
    } else {
      throw Exception();
    }*/
    //print('Сейчас ходит $activeCellIndex. Действие - $action. Глубина - ${context.currentTreeDepth}');
    if (isMax) {
      var maxEval = -double.infinity;
      assert(currentPossibleActions.isNotEmpty);
      for (var cpa in currentPossibleActions) {
        final res = _bypass(
          context: context,
          action: cpa,
          //snapshot: currentSnapshot.getSnapshot(),
          snapshot: currentSnapshot,
          //branchNumber: branchNumber,
          activeCellIndex: newActiveCellIndex,
          alpha: alpha,
          beta: beta,
        );
        //print('Походил $newActiveCellIndex. '
        //    'Действие $cpa. '
        //    'Результат ${res.value}. Это ${isMax ? 'MAX' : 'MIN'}');
        maxEval = max(res.value, maxEval);
        alpha = max(alpha, res.value);
        if (beta <= alpha) {
          //print('Обрезка');
          break;
        }
      }
      context.currentTreeDepth--;
      return _ABPruningReturnValue(value: maxEval);

    } else if (isMin) {
      var minEval = double.infinity;
      assert(currentPossibleActions.isNotEmpty);
      for (var cpa in currentPossibleActions) {
        final res = _bypass(
          context: context,
          action: cpa,
          //snapshot: currentSnapshot.getSnapshot(),
          snapshot: currentSnapshot,
          //branchNumber: branchNumber,
          activeCellIndex: newActiveCellIndex,
          alpha: alpha,
          beta: beta,
        );
        //print('Походил $newActiveCellIndex. '
        //    'Действие $cpa. '
        //    'Результат ${res.value}. Это ${isMax ? 'MAX' : 'MIN'}');
        minEval = min(res.value, minEval);
        beta = min(beta, res.value);
        if (beta <= alpha) {
          //print('Обрезка');
          break;
        }
      }
      context.currentTreeDepth--;
      return _ABPruningReturnValue(value: minEval);
    } else {
      throw Exception();
    }

  }

  /// Чем больше раздамажены юниты игрока, тем меньшее значение вернёт ф-ия
  double _enemyFitness(List<Unit> units, {bool forTopTeam = true}) {
    // Подсчёт приспособленности
    // для начала это будет суммарное оставшееся ХП + число раундов
    final aisUnitsHp = <int>[];
    final aisUnitsMaxHp = <int>[];

    //final enemyUnitsHp = <int>[];
    //final enemyUnitsMaxHp = <int>[];

    int index = 0;
    for (var u in units) {
      if (checkIsTopTeam(index)) {
        aisUnitsHp.add(u.currentHp);
        aisUnitsMaxHp.add(u.maxHp);
      } else {
        //enemyUnitsHp.add(u.currentHp);
        //enemyUnitsMaxHp.add(u.maxHp);
      }
      index++;
    }
    final hpFit = aisUnitsHp.sum / aisUnitsMaxHp.sum;
    //final hpFitEnemy = 1 - enemyUnitsHp.sum / enemyUnitsMaxHp.sum;

    return hpFit;
  }

  /// Чем больше раздамажены враги, тем большее значение вернёт функция
  double _calculateFitness(List<Unit> units, {bool forTopTeam = true}) {
    // Подсчёт приспособленности
    // для начала это будет суммарное оставшееся ХП + число раундов
    final aisUnitsHp = <int>[];
    final aisUnitsMaxHp = <int>[];

    final enemyUnitsHp = <int>[];
    final enemyUnitsMaxHp = <int>[];

    int index = 0;
    int aiUnitsCount = 0;
    int aiUnitsDead = 0;
    for (var u in units) {
      if (checkIsTopTeam(index)) {
        aisUnitsHp.add(u.currentHp);
        aisUnitsMaxHp.add(u.maxHp);
        aiUnitsCount++;
        if (u.isDead) {
          aiUnitsDead++;
        }
      } else {
        enemyUnitsHp.add(u.currentHp);
        enemyUnitsMaxHp.add(u.maxHp);
      }
      index++;
    }
    //final hpFit = aisUnitsHp.sum / aisUnitsMaxHp.sum;

    /// Statistic Function Ratio
    var sfr = 0.0;

    // Как раздамажен соперник
    sfr += (1.0 - enemyUnitsHp.sum / enemyUnitsMaxHp.sum) * 0.33;
    // Сколько своих погибло
    sfr += (1.0 - aiUnitsDead/aiUnitsCount) * 0.33;
    // Как раздамажен свой отряд
    sfr += (aisUnitsHp.sum / aisUnitsMaxHp.sum) * 0.33;

    //var hpFitEnemy = 1 - enemyUnitsHp.sum / enemyUnitsMaxHp.sum;
    //hpFitEnemy -= (1.0 - aiUnitsCount/aiUnitsDead);

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