import 'dart:collection';
import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/update_state_context/update_state_context_base.dart';

import 'attack_controller.dart';
import 'initiative_shuffler.dart';


class GameController {
  AttackController attackController;
  InitiativeShuffler initiativeShuffler;

  GameController(
      {required this.attackController, required this.initiativeShuffler});

  GameController copyWith({
    attackController,
    initiativeShuffler
  }) {
    return GameController(
    attackController: attackController ?? this.attackController,
    initiativeShuffler: initiativeShuffler ?? this.initiativeShuffler,
  );
}

  /// Ссылки на юнитов на поле боя. Используются очередью
  List<Unit> unitsRef = [];

  /// Ссылки на юнитов на поле боя
  List<Unit> units = [];

  /// ID юнита - положение на поле поле боя
  Map<String, int> unitPosition = {};

  /// Очередь юнитов. Пополняется после сортировки по инициативе
  Queue<Unit>? unitsQueue;

  bool inited = false;
  bool gameStarted = false;

  int? currentActiveCellIndex;

  int currentRound = 0;

  void reset() {
    unitsRef = [];
    currentRound = 0;
    inited = false;
    gameStarted = false;
    unitPosition.clear();
    unitsQueue = null;
    units = [];
  }

  ResponseAction init(List<Unit> units) {
    bool topTeamHasUnits = false;
    bool bottomTeamHasUnits = false;

    var index = 0;
    for (var unit in units) {
      if (unit.isEmpty()) {
        index++;
        continue;
      }

      if (index <= 5) {
        topTeamHasUnits = true;
      } else if (index > 5 && index <= 11) {
        bottomTeamHasUnits = true;
      } else {
        assert(false);
      }

      unitsRef.add(unit);
      unitPosition[unit.unitWarId] = index;

      index++;
    }

    if (!topTeamHasUnits || !bottomTeamHasUnits) {
      return ResponseAction.error("У одной из команд нет юнитов",
          roundNumber: currentRound, activeCell: -1);
    }

    this.units = units;

    inited = true;

    return ResponseAction.success(roundNumber: currentRound, activeCell: -1);
  }

  ResponseAction startGame() {
    if (!inited) {
      return ResponseAction.error("Контроллер не инициализирован",
          activeCell: -1, roundNumber: currentRound);
    }
    if (gameStarted) {
      return ResponseAction.error("Игра ужа начата",
          activeCell: -1, roundNumber: currentRound);
    }
    gameStarted = true;
    _startNewRound();

    final currentActiveUnit = unitsQueue!.removeFirst();

    currentActiveCellIndex = unitPosition[currentActiveUnit.unitWarId];

    for (var i = 0; i < units.length; i++) {
      if (i == currentActiveCellIndex!) {
        units[i] = units[i].copyWith(isMoving: true);
      } else {
        units[i] = units[i].copyWith(isMoving: false);
      }
    }

    return ResponseAction.success(
        activeCell: currentActiveCellIndex!,
        message: "Старт PVP",
        roundNumber: currentRound);
  }

  Future<ResponseAction> makeAction(RequestAction action) async {

    //print(action);

    /// Конец игры, если у одной из команд не осталось живых юнитов
    bool topTeamHasNoDeadUnits = false;
    bool bottomTeamHasNoDeadUnits = false;
    var index = 0;
    for (var unit in units) {
      if (unit.isEmpty()) {
        index++;
        continue;
      }
      if (index <= 5) {
        if (!unit.isDead) {
          topTeamHasNoDeadUnits = true;
        }
      } else if (index > 5 && index <= 11) {
        if (!unit.isDead) {
          bottomTeamHasNoDeadUnits = true;
        }
      } else {
        assert(false);
      }
      index++;
    }
    if (!(topTeamHasNoDeadUnits && bottomTeamHasNoDeadUnits)) {
      return ResponseAction.endGame(roundNumber: currentRound);
    }

    switch (action.type) {
      case ActionType.click:
        if (action.targetCellIndex == null) {
          return ResponseAction.error('Тип действия атака, но нет цели',
              roundNumber: currentRound, activeCell: currentActiveCellIndex!);
        }
        if (currentActiveCellIndex == null) {
          return ResponseAction.error(
              'Тип действия атака, но нет активного юнита',
              roundNumber: currentRound,
              activeCell: currentActiveCellIndex!);
        }
        /*units[currentActiveCellIndex!] =
            units[currentActiveCellIndex!].copyWith(isWaiting: false);*/
        return await _handleClick(action);

      case ActionType.wait:
        return await _handleWait(action);
      case ActionType.protect:
        // Если юнит ждал, то ожидание снимается только после хода
        units[currentActiveCellIndex!] =
            units[currentActiveCellIndex!].copyWith(isWaiting: false);
        return await _handleProtect(action);

      case ActionType.startGame:
        throw Exception();
      case ActionType.endGame:
        throw Exception();
      case ActionType.retreat:
        assert(!units[currentActiveCellIndex!].retreat);
        assert(currentActiveCellIndex != null);
        return await _handleRetreat(action);
    }
  }

  /// Получить из очереди [unitsQueue] следующего юнита
  /// Если очередь пуста, будет сделана попытка начать новый раунд
  /// Если раунд не удалось начать - конец игры
  /// [waiting] true, если до вызова метода было действие ждать
  Future<ResponseAction> _getNextUnit(
    RequestAction action, {
    bool handleDoubleAttack = false,
    bool waiting = false,
    bool protecting = false,
    bool retriting = false,
  }) async {
    if (handleDoubleAttack) {
      final currentUnit = units[currentActiveCellIndex!];
      if (currentUnit.isDoubleAttack) {
        if (currentUnit.currentAttack == 0) {
          units[currentActiveCellIndex!] =
              units[currentActiveCellIndex!].copyWith(
            currentAttack: 1,
          );
          return ResponseAction.success(
            roundNumber: currentRound,
            activeCell: currentActiveCellIndex!,
          );
        }
        units[currentActiveCellIndex!] =
            units[currentActiveCellIndex!].copyWith(
          currentAttack: 0,
        );
      }
    }

    String? currentActiveUnitID;

    await attackController.unitMovePostProcessing(
        currentActiveCellIndex!, units,
        retriting: retriting, waiting: waiting, protecting: protecting);

    while (true) {
      if (unitsQueue!.isEmpty) {
        if (!_startNewRound()) {
          print('Не удалось начать новый раунд');
          return ResponseAction.endGame(roundNumber: currentRound);
        }
      }

      currentActiveUnitID = unitsQueue!.removeFirst().unitWarId;
      final currentActiveUnitIndex = unitPosition[currentActiveUnitID];
      assert(currentActiveUnitIndex != null);

      // Проверка контроллером атак перед ходом
      if (!await attackController.unitMovePreprocessing(
          currentActiveUnitIndex!, units,
          updateStateContext: action.context,
          retriting: retriting,
          waiting: waiting,
          protecting: protecting)) {
        //print('Юнит пропускает ход');
        // Если текщий активный юнит защищался, защита снимается
        units[currentActiveUnitIndex] =
            units[currentActiveUnitIndex].copyWith(isProtected: false);
        // Если до этого юнит ждал, ожидание снимается
        units[currentActiveUnitIndex] =
            units[currentActiveUnitIndex].copyWith(isWaiting: false);
        if (units[currentActiveUnitIndex].isDead) {
          //print('Мертвый не ходит!');
          units[currentActiveUnitIndex] =
              units[currentActiveUnitIndex].copyWithDead();
          continue;
        }
        continue;
      }

      if (units[currentActiveUnitIndex].isDead) {
        //print('Мертвый не ходит!');
        units[currentActiveUnitIndex] =
            units[currentActiveUnitIndex].copyWithDead();
        continue;
      }

      if (units[currentActiveUnitIndex].retreat) {
        //print('Юнит отступил');
        units[currentActiveUnitIndex] = Unit.empty();
        continue;
      }

      break;
    }

    currentActiveCellIndex = unitPosition[currentActiveUnitID];
    assert(currentActiveCellIndex != null);

    for (var i = 0; i < units.length; i++) {
      if (i == currentActiveCellIndex!) {
        units[i] = units[i].copyWith(isMoving: true);
      } else {
        units[i] = units[i].copyWith(isMoving: false);
      }
    }

    // Если текщий активный юнит защищался, защита снимается
    units[currentActiveCellIndex!] =
        units[currentActiveCellIndex!].copyWith(isProtected: false);

    return ResponseAction.success(activeCell: currentActiveCellIndex);
  }

  Future<ResponseAction> _handleClick(RequestAction action) async {
    ResponseAction responseAction = await attackController.applyAttack(
      currentActiveCellIndex!,
      action.targetCellIndex!,
      units,
      ResponseAction(
          message: "",
          success: false,
          endGame: false,
          roundNumber: currentRound,
          //activeCell: currentActiveCellIndex!,
      ),
      updateStateContext: action.context,
      onAddUnit2Queue: _onUnitAdded2Queue,
    );

    if (!responseAction.success) {
      return responseAction;
    }
    // Снимается ожидание только тогда, когда клик удачный
    units[currentActiveCellIndex!] =
        units[currentActiveCellIndex!].copyWith(isWaiting: false);

    return await _getNextUnit(action, handleDoubleAttack: true);
  }

  void _onUnitAdded2Queue(Unit unit) {
    assert(unitsQueue != null);
    unitsQueue!.addFirst(unit);
  }

  Future<ResponseAction> _handleWait(RequestAction action) async {
    final currentUnit = units[currentActiveCellIndex!];

    if (currentUnit.currentAttack == 1) {
      return ResponseAction.error('Юнит не может ждать на второй атаке',
          roundNumber: currentRound, activeCell: currentActiveCellIndex!);
    }

    if (currentUnit.isWaiting) {
      return ResponseAction.error('Ждущий юнит не может ждать ещё раз',
          roundNumber: currentRound, activeCell: currentActiveCellIndex!);
    }

    assert(!currentUnit.isProtected);
    //assert(currentUnit.isMoving);
    if (!currentUnit.isMoving) {
      print('asd');
      throw Exception();
    }
    assert(!currentUnit.isEmpty());
    units[currentActiveCellIndex!] =
        units[currentActiveCellIndex!].copyWith(isWaiting: true);

    // Помещаем юнита в конец очереди
    unitsQueue!.add(currentUnit);

    return await _getNextUnit(
        action,
        waiting: true
    );
  }

  Future<ResponseAction> _handleRetreat(RequestAction action) async {
    units[currentActiveCellIndex!] =
        units[currentActiveCellIndex!].copyWith(retreat: true);

    return await _getNextUnit(
        action,
        retriting: true);
  }

  Future<ResponseAction> _handleProtect(RequestAction action) async {
    final currentUnit = units[currentActiveCellIndex!];

    // todo Нв второй атаке, когда все фуловые, невозможнол ничего сделать
    // todo пока костыль, вторая атака не учитывается. Нужно учитывать!
    /*if (currentUnit.currentAttack == 1 && currentUnit.unitAttack.attackClass == AttackClass.L_DAMAGE) {
      return ResponseAction.error('Юнит не может защищаться на второй атаке',
          roundNumber: currentRound, activeCell: currentActiveCellIndex!);
    }*/

    // Если юнит уже защищён, то что-то не то
    assert(!units[currentActiveCellIndex!].isProtected);
    units[currentActiveCellIndex!] =
        units[currentActiveCellIndex!].copyWith(isProtected: true);
    return await _getNextUnit(
        action,
        protecting: true);
  }

  bool _startNewRound() {
    unitsRef = [];
    for (var unit in units) {
      if (!unit.isEmpty() && !unit.isDead) {
        unitsRef.add(unit);
      }
    }
    if (unitsRef.isEmpty) {
      return false;
    }
    _sortUnitsByInitiative();
    currentRound += 1;
    //print('Новый раунд - $currentRound');
    return true;
  }

  void _sortUnitsByInitiative() {
    // todo Механики игры используют не строгую сортировку!
    // todo У второй атаки тоже есть инициатива. Не пон7ятно какую юзать
    /*unitsRef.sort((a, b) =>
        b.unitAttack.initiative.compareTo(a.unitAttack.initiative));*/
    initiativeShuffler.shuffleAndSort(unitsRef);
    unitsQueue = Queue<Unit>.from(unitsRef);
  }

  List<bool> _cellHasUnit() {
    return units.map((e) {
      if (e.isDead || e.isEmpty()) {
        return false;
      }
      return true;
    }).toList();
  }
}

class RequestAction {
  final int? currentCellIndex;
  final int? targetCellIndex;
  final UpdateStateContextBase? context;

  final ActionType type;

  RequestAction({
    required this.type,
    required this.targetCellIndex,
    required this.currentCellIndex,
    this.context,
  });

  RequestAction copyWith({currentCellIndex, targetCellIndex, context, type}) {
    return RequestAction(
      type: type ?? this.type,
      targetCellIndex: targetCellIndex ?? this.targetCellIndex,
      currentCellIndex: currentCellIndex ?? this.currentCellIndex,
      context: context ?? this.context,
    );
  }

  @override
  String toString() {
    print('-------- ACTION START --------');
    print("Новое действие. Тип действия - ${type.toString().split('.').last}");
    print('Текущий юнит $currentCellIndex, цель - $targetCellIndex');
    print('-------- ACTION END --------');

    return super.toString();
  }
}

enum ActionType { click, wait, protect, retreat, startGame, endGame }

class ResponseAction {
  final String message;
  final bool success;
  final int? activeCell;
  final bool endGame;
  final int? roundNumber;

  ResponseAction({
    required this.message,
    required this.success,
    this.activeCell,
    required this.endGame,
    this.roundNumber,
  });

  ResponseAction copyWith({
    message,
    success,
    activeCell,
    endGame,
    roundNumber,
  }) {
    return ResponseAction(
      message: message ?? this.message,
      success: success ?? this.success,
      activeCell: activeCell ?? this.activeCell,
      endGame: endGame ?? this.endGame,
      roundNumber: roundNumber ?? this.roundNumber,
    );
  }

  ResponseAction copyWithError({
    message,
    activeCell,
    endGame,
    roundNumber,
  }) {
    return ResponseAction(
      message: message ?? this.message,
      success: false,
      activeCell: activeCell ?? this.activeCell,
      endGame: endGame ?? this.endGame,
      roundNumber: roundNumber ?? this.roundNumber,
    );
  }

  ResponseAction copyWithSuccess({
    message,
    activeCell,
    endGame,
    roundNumber,
  }) {
    return ResponseAction(
      message: message ?? this.message,
      success: true,
      activeCell: activeCell ?? this.activeCell,
      endGame: endGame ?? this.endGame,
      roundNumber: roundNumber ?? this.roundNumber,
    );
  }

  factory ResponseAction.success(
      {String? message, int? activeCell, int? roundNumber}) {
    return ResponseAction(
      message: message ?? "",
      success: true,
      activeCell: activeCell,
      endGame: false,
      roundNumber: roundNumber,
    );
  }

  factory ResponseAction.error(String message,
      {int? activeCell, int? roundNumber}) {
    return ResponseAction(
      message: message,
      success: false,
      activeCell: activeCell,
      endGame: false,
      roundNumber: roundNumber,
    );
  }

  factory ResponseAction.endGame({required int roundNumber}) {
    return ResponseAction(
      message: "Конец игры",
      success: true,
      endGame: true,
      roundNumber: roundNumber,
      activeCell: -1,
    );
  }

  @override
  String toString() {

    print("------- RESPONSE ACTION -----");

    return super.toString();
  }
}
