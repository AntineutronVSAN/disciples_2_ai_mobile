import 'dart:async';
import 'dart:collection';
import 'package:d2_ai_v2/controllers/attack_controller/postprocessing_part/postprocessing_part.dart';
import 'package:d2_ai_v2/controllers/attack_controller/preprocessing_part/preprocessing_part.dart';
import 'package:d2_ai_v2/controllers/game_controller/roll_config.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/repositories/game_repository.dart';
import 'package:d2_ai_v2/repositories/game_repository_base.dart';

import '../attack_controller/attack_controller.dart';
import '../initiative_shuffler.dart';
import 'actions.dart';


class GameController {

  AttackController attackController;
  InitiativeShuffler initiativeShuffler;
  GameRepositoryBase gameRepository;

  RollConfig rollConfig = RollConfig(
      topTeamMaxPower: false,
      bottomTeamMaxPower: false,
      topTeamMaxIni: false,
      bottomTeamMaxIni: false,
      topTeamMaxDamage: false,
      bottomTeamMaxDamage: false,
  );

  GameController(
      {required this.attackController, required this.initiativeShuffler,
      required this.gameRepository});

  GameController copyWith({
    attackController,
    initiativeShuffler,
    gameRepository,
  }) {
    return GameController(
    attackController: attackController ?? this.attackController,
    initiativeShuffler: initiativeShuffler ?? this.initiativeShuffler,
    gameRepository: gameRepository ?? this.gameRepository,
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
  /// И копия не обновляет UI
  GameController getSnapshot() {
    GameController snapshot = GameController(
      attackController: attackController.deepCopy(),
        /*attackController: AttackController(
            attackDurationController: attackController.attackDurationController,
            powerController: attackController.powerController,
            damageScatter: attackController.damageScatter,
          gameRepository: gameRepository
        )*/
        initiativeShuffler: initiativeShuffler, gameRepository: gameRepository);

    snapshot.inited = inited;
    snapshot.currentRound = currentRound;
    snapshot.gameStarted = gameStarted;
    snapshot.currentActiveCellIndex = currentActiveCellIndex;

    //snapshot.units = units.map((e) => e.deepCopy()).toList(); TODO OPT
    //snapshot.units = List.generate(12, (index) => Unit.empty());

    snapshot.units = [
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
      GameRepositoryBase.globalEmptyUnit,
    ];
    int index=0;

    final unitsRefIdMap = <String, Unit>{};

    for(var i in units) {
      if (i.isNotEmpty()) {
        final currentSnapshotsUnit = i.deepCopy();
        snapshot.units[index] = currentSnapshotsUnit;
        unitsRefIdMap[i.unitWarId] = currentSnapshotsUnit;
      } else {
        unitsRefIdMap[i.unitWarId] = GameRepositoryBase.globalEmptyUnit;
      }
      index++;
    }

    snapshot.unitsRef = [];
    for(var i in unitsRef) {
      //List<Unit> u = [];
      //u.add(unitsRefIdMap[i.unitWarId]!);
      if (unitsRefIdMap[i.unitWarId] == null) {
        print('asdfasdfasdfasdf');
      }
      snapshot.unitsRef.add(unitsRefIdMap[i.unitWarId]!);
    }
    /*for(var i in unitsRef) {
      //final u = snapshot.units.where((element) => element.unitWarId == i.unitWarId).toList();
      List<Unit> u = [];
      for (var j in snapshot.units) {
        if (j.unitWarId == i.unitWarId) {
          u.add(j);
        }
      }
      snapshot.unitsRef.add(u[0]);
    }*/

    //assert(unitsRef.length == snapshot.unitsRef.length);

    final newQueue = Queue<Unit>();
    for(var i in unitsQueue!) {
      //List<Unit> u = [];
      //u.add(unitsRefIdMap[i.unitWarId]!);
      if (unitsRefIdMap[i.unitWarId] == null) {
        print('asdfasdfasdfasdf');
      }
      newQueue.add(unitsRefIdMap[i.unitWarId]!);
    }
    /*for(var i in unitsQueue!) {
      //final u = snapshot.units.where((element) => element.unitWarId == i.unitWarId).toList();
      //assert(u.length == 1);
      List<Unit> u = [];
      for(var j in snapshot.units) {
        if (j.unitWarId == i.unitWarId) {
          u.add(j);
        }
      }
      newQueue.add(u[0]);
    }*/

    snapshot.unitsQueue = newQueue;
    //assert(units.length == snapshot.units.length);
    //assert(unitsQueue!.length == snapshot.unitsQueue!.length);


    snapshot.unitPosition = unitPosition.map((key, value) => MapEntry(key, value));

    //snapshot.rollConfig = rollMaxRandomParamsBotTeam;
    //snapshot.rollMaxRandomParamsTopTeam = rollMaxRandomParamsTopTeam;
    snapshot.rollConfig = rollConfig.deepCopy();

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
        final emptyUnit = GameRepositoryBase.globalEmptyUnit;
        final retreatedUnitWarId = units[currentActiveUnitIndex].unitWarId;
        int? retreatedUnitRefIndex;
        int index = 0;
        for(var i in unitsRef) {
          if (i.unitWarId == retreatedUnitWarId) {
            retreatedUnitRefIndex = index;
            break;
          }
          index++;
        }
        assert(retreatedUnitRefIndex != null);

        units[currentActiveUnitIndex] = emptyUnit;
        unitsRef[retreatedUnitRefIndex!] = emptyUnit;
        unitsQueue!.removeWhere((element) => element.unitWarId == retreatedUnitWarId);
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
      rollConfig: rollConfig,
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
    //final currentUnit = units[currentActiveCellIndex!];

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
    initiativeShuffler.shuffleAndSort(
      unitsRef,
      rollConfig: rollConfig,
    );
    unitsQueue = Queue<Unit>.from(unitsRef);
  }
}
