

import 'package:d2_ai_v2/controllers/game_controller/actions.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/utils/cell_utils.dart';

class ActionsOrderController {

  static const List<int> topMiliIndexes = [12, 6,7,8, 13, 9,10,11, 0,1,2,3,4,5];
  static const List<int> botMiliIndexes = [12, 3,4,5, 13, 0,1,2,   6,7,8,9,10,11];
  static const List<int> topRange = [11,10,9,8,7,6, 13,12,  5,4,3,2,1,0];
  static const List<int> botRange = [0,1,2,3,4,5,   13,12,  6,7,8,9,10,11];

  /// Список всех возможных действий
  List<RequestAction> getAllPossibleActions() {
    return [
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
  }

  /// Получить список с порядком действий.
  /// Элементы списка - индексы действий [possibleActions]
  /// Действия должны быть в порядке (можно увидеть в методе [getAllPossibleActions]):
  /// [0,1,2,3,4,5,6,7,8,9,10,11, 12,13] - Где 12 - 13 защита и ждать
  /// Элементы нового списка действий ссылаются на элементы [possibleActions]
  /// Для магов вернётся сслыка на [possibleActions]
  List<RequestAction> getOrderActions({
    required List<RequestAction> possibleActions,
    required List<Unit> units,
    required int current,
  }) {
    final result = <RequestAction>[];

    /*

    Топ милишник - [12, 6,7,8, 13, 9,10,11, 0,1,2,3,4,5]
    Бот милишник - [12, 3,4,5, 13, 0,1,2,   6,7,8,9,10,11]

    Топ стрелок - [11,10,9,8,7,6, 13,12,  5,4,3,2,1,0]
    Бот стрелок - [0,1,2,3,4,5,   13,12,  6,7,8,9,10,11]

    //todo хилы, призыватели и т.п по разному
    */



    final currentIsTopTeam = checkIsTopTeam(current);
    //final currentUnit = units[current];
    final currentUnitAttack = units[current].unitAttack;

    List<int> newIndexes;

    // По началу будет только проверка для лучников
    switch(currentUnitAttack.targetsCount) {

      case TargetsCount.one:
        if (currentIsTopTeam) {
          newIndexes = topMiliIndexes;
        } else {
          newIndexes = botMiliIndexes;
        }
        break;
      case TargetsCount.any:
        if (currentIsTopTeam) {
          newIndexes = topRange;
        } else {
          newIndexes = botRange;
        }
        break;
      case TargetsCount.all:
        return possibleActions;
    }

    for(var i in newIndexes) {
      result.add(possibleActions[i]);
    }

    return result;
  }




  static const List<int> normalOrderActions = [
    0,1,2,3,4,5,6,7,8,9,10,11  ,12,13
  ];
  static const List<int> reversedOrderActions = [
    11,10,9,8,7,6,5,4,3,2,1    ,12,13
  ];
  /// Получить порядок извлечения действий, в зависимости от чиста
  /// целей юнита. Основная идея в том, что если юнит бьёт любого, то
  /// начать перебирать цели стоит с заднего ряда соперника
  /// Дальше, можно будет ещё учесть ценности юнитов и выбирать
  /// наиболее ценный таргет
  List<int> orderedActions({required int current, required List<Unit> units}) {

    final currentTopTeam = checkIsTopTeam(current);
    final currentUnit = units[current];

    final currentUnitTargets = units[current].unitAttack.targetsCount;

    final targetsCountAny = currentUnitTargets == TargetsCount.any;

    if (targetsCountAny) {
      if (currentTopTeam) {
        return reversedOrderActions;
      }
    }
    return normalOrderActions;
  }

}