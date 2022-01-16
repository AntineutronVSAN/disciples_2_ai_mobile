import 'dart:collection';
import 'package:d2_ai_v2/controllers/attack_controller/sync_attack_controller.dart';
import 'package:d2_ai_v2/models/unit.dart';
import '../initiative_shuffler.dart';
import 'actions.dart';


class SyncGameController {
  SyncAttackController attackController;
  InitiativeShuffler initiativeShuffler;

  /// Если true, все случайные параметры для верхней команды будут максимальными
  bool rollMaxRandomParamsTopTeam = false;
  /// Если true, все случайные параметры для нижней команды будут максимальными
  bool rollMaxRandomParamsBotTeam = false;

  SyncGameController(
      {required this.attackController, required this.initiativeShuffler});

  SyncGameController copyWith({
    attackController,
    initiativeShuffler
  }) {
    return SyncGameController(
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

  /// Получить копию текущего контроллера игры. Важно учесть, что
  /// копия имеет ссылки на контролеры оригинала
  SyncGameController getSnapshot() {
    SyncGameController snapshot = SyncGameController(
        attackController: attackController,
        initiativeShuffler: initiativeShuffler);

    snapshot.inited = inited;
    snapshot.currentRound = currentRound;
    snapshot.gameStarted = gameStarted;
    snapshot.currentActiveCellIndex = currentActiveCellIndex;

    final tempUnitsMap = <String, Unit>{};
    snapshot.units = [];
    for(var u in units) {
      final newUnit = u.deepCopy();
      final newUnitId = newUnit.unitWarId;
      snapshot.units.add(newUnit);
      tempUnitsMap[newUnitId] = newUnit;
    }
    snapshot.unitsRef = [];
    for(var i in unitsRef) {
      snapshot.unitsRef.add(tempUnitsMap[i.unitWarId]!);
    }
    final newQueue = Queue<Unit>();
    for(var i in unitsQueue!) {
      newQueue.add(tempUnitsMap[i.unitWarId]!);
    }
    snapshot.unitsQueue = newQueue;

    //assert(units.length == snapshot.units.length);
    //assert(unitsQueue!.length == snapshot.unitsQueue!.length);
    snapshot.rollMaxRandomParamsBotTeam = rollMaxRandomParamsBotTeam;
    snapshot.rollMaxRandomParamsTopTeam = rollMaxRandomParamsTopTeam;

    snapshot.unitPosition = unitPosition.map((key, value) => MapEntry(key, value));
    return snapshot;
  }

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

  ResponseAction makeAction(RequestAction action) {

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
        return _handleClick(action);

      case ActionType.wait:
        return _handleWait(action);
      case ActionType.protect:
      // Если юнит ждал, то ожидание снимается только после хода
        units[currentActiveCellIndex!] =
            units[currentActiveCellIndex!].copyWith(isWaiting: false);
        return  _handleProtect(action);

      case ActionType.startGame:
        throw Exception();
      case ActionType.endGame:
        throw Exception();
      case ActionType.retreat:
        assert(!units[currentActiveCellIndex!].retreat);
        assert(currentActiveCellIndex != null);
        return  _handleRetreat(action);
    }
  }

  /// Получить из очереди [unitsQueue] следующего юнита
  /// Если очередь пуста, будет сделана попытка начать новый раунд
  /// Если раунд не удалось начать - конец игры
  /// [waiting] true, если до вызова метода было действие ждать
  ResponseAction _getNextUnit(
      RequestAction action, {
        bool handleDoubleAttack = false,
        bool waiting = false,
        bool protecting = false,
        bool retriting = false,
      })  {
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

    attackController.unitMovePostProcessing(
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
      if (! attackController.unitMovePreprocessing(
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

  ResponseAction _handleClick(RequestAction action)  {
    ResponseAction responseAction =  attackController.applyAttack(
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
      rollMaxForTop: rollMaxRandomParamsTopTeam,
      rollMaxForBot: rollMaxRandomParamsBotTeam,
    );

    if (!responseAction.success) {
      return responseAction;
    }
    // Снимается ожидание только тогда, когда клик удачный
    units[currentActiveCellIndex!] =
        units[currentActiveCellIndex!].copyWith(isWaiting: false);

    return  _getNextUnit(action, handleDoubleAttack: true);
  }

  void _onUnitAdded2Queue(Unit unit) {
    assert(unitsQueue != null);
    unitsQueue!.addFirst(unit);
  }

  ResponseAction _handleWait(RequestAction action)  {
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

    return  _getNextUnit(
        action,
        waiting: true
    );
  }

  ResponseAction _handleRetreat(RequestAction action)  {
    units[currentActiveCellIndex!] =
        units[currentActiveCellIndex!].copyWith(retreat: true);

    return  _getNextUnit(
        action,
        retriting: true);
  }

  ResponseAction _handleProtect(RequestAction action)  {
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
    return  _getNextUnit(
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
    initiativeShuffler.shuffleAndSort(
      unitsRef,
      rollMaxIniForBot: rollMaxRandomParamsBotTeam,
      rollMaxIniForTop: rollMaxRandomParamsTopTeam,
    );
    unitsQueue = Queue<Unit>.from(unitsRef);
  }
}
