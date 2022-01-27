
import 'package:d2_ai_v2/ai_controller/ai_controller_base.dart';
import 'package:d2_ai_v2/bloc/states.dart';
import 'package:d2_ai_v2/controllers/game_controller/actions.dart';
import 'package:d2_ai_v2/controllers/game_controller/game_controller.dart';
import 'package:d2_ai_v2/controllers/unit_upgrade_controller/unit_upgrade_controller.dart';
import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/repositories/game_repository.dart';
import 'package:d2_ai_v2/update_state_context/update_state_context.dart';
import 'package:d2_ai_v2/utils/cell_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../units_pack.dart';
import 'events.dart';

import 'dart:math';

class GameBloc extends Bloc<GameEvent, GameState> {
  final rng = Random();
  final uuid = const Uuid();

  final GameRepository repository;
  final GameController controller;
  final AiControllerBase aiController;

  // TODO Ему сдесь не место
  final UnitUpgradeController unitUpgradeController = UnitUpgradeController();

  final List<Unit> _allUnits = [];

  /// Ключ - id юнита в игре (не путить с id в битве)
  final Map<String, Unit> _allUnitsMap = {};

  final List<Unit> _units = [];

  /// Копии юнитов, они отправляются в контроллер битвы, что бы не терять
  /// оригинальных
  final List<Unit> _warUnitsCopies = [];

  bool canAcceptNewEvent = true;

  /// Счётчик совершённых невозможных действий от ИИ
  int impossibleAiActions = 0;

  GameBloc(
    GameState initialState, {
    required this.repository,
    required this.controller,
    required this.aiController,
  }) : super(initialState) {
    _units.addAll([
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
    ]);
    repository.init();
    _allUnits.addAll(repository.getAllUnits());
    for (var element in _allUnits) {
      _allUnitsMap[element.unitGameID] = element;
    }
    initialState.allUnits.addAll(_allUnits);

    initialState.units.addAll(_units);

    on<OnPVPStartedEvent>(
        (event, emit) => _handleEvent(() => _onPVPStarted(event, emit)));
    on<OnPVEStartedEvent>(
        (event, emit) => _handleEvent(() => _onPVEStarted(event, emit)));
    on<OnEVEStartedEvent>(
        (event, emit) => _handleEvent(() => _onEVEStarted(event, emit)));

    on<OnCellTapEvent>(
        (event, emit) => _handleEvent(() => _onCellTap(event, emit)));
    on<OnCellLongTapEvent>(
        (event, emit) => _handleEvent(() => _onCellLongTap(event, emit)));

    on<OnUnitSelected>(
        (event, emit) => _handleEvent(() => _onUnitSelected(event, emit)));

    on<OnReset>((event, emit) => _handleEvent(() => _onReset(event, emit)));

    on<OnUnitProtectClick>(
        (event, emit) => _handleEvent(() => _onProtect(event, emit)));
    on<OnUnitWaitClick>(
        (event, emit) => _handleEvent(() => _onWait(event, emit)));

    on<OnRetreat>((event, emit) => _handleEvent(() => _onRetreat(event, emit)));

    on<OnUnitsListFilters>(
        (event, emit) => _handleEvent(() => _onUnitsListFilters(event, emit)));

    on<OnUnitsLoad>(
        (event, emit) => _handleEvent(() => _onUnitsLoad(event, emit)));
  }

  Future<void> _handleEvent(Function() func) async {
    if (canAcceptNewEvent) {
      canAcceptNewEvent = false;
      await func();
      canAcceptNewEvent = true;
    }
  }

  @override
  void onChange(Change<GameState> change) {
    // TODO: implement onChange
    super.onChange(change);
  }

  Future<void> _onUnitsLoad(OnUnitsLoad event, Emitter emit) async {

    final List<String> unitsNames = UnitsPack.packs[2];
    //final List<String> unitsNames = UnitsPack.tournaments[9];

    assert(unitsNames.length == 12);
    var index = 0;
    for (var name in unitsNames) {

      //if ((index+1) % 2 == 0) {
      if ((2) % 2 == 0) {
        _units[index] = repository.getRandomUnit();
      }
      // TODO Тестирую уровни
      unitUpgradeController.setLevel(9, index, _units);

      _units[index] = repository.getCopyUnitByName(name);

      index++;
    }

    emit(state.copyWith(units: _units));
  }

  Future<void> _onUnitsListFilters(
      OnUnitsListFilters event, Emitter emit) async {
    if (state.warScreenState == WarScreenState.view) {
      final subString = event.unitName;
      final subStringLen = event.unitName.length;

      emit(state.copyWith(
          allUnits: _allUnits.where((element) {
        final name = element.unitName;
        if (subStringLen > name.length) {
          return false;
        }
        return name.substring(0, subStringLen) == subString;
      }).toList()));
    }
  }

  Future<void> _onRetreat(OnRetreat event, Emitter emit) async {
    final action = RequestAction(
        type: ActionType.retreat,
        currentCellIndex: null,
        targetCellIndex: null);
    final response = await controller.makeAction(action);
    if (!handleResponse(response)) {
      return;
    }
    emit(state.copyWith(
      units: _warUnitsCopies,
    ));
    if (checkIsTopTeam(response.activeCell!) &&
        state.warScreenState == WarScreenState.pve) {
      await _handleAiMove(response, emit);
    }
  }

  Future<void> _onWait(OnUnitWaitClick event, Emitter emit) async {
    final action = RequestAction(
        type: ActionType.wait, currentCellIndex: null, targetCellIndex: null);
    final response = await controller.makeAction(action);
    if (!handleResponse(response)) {
      return;
    }
    emit(state.copyWith(
      units: _warUnitsCopies,
    ));
    if (checkIsTopTeam(response.activeCell!) &&
        state.warScreenState == WarScreenState.pve) {
      await _handleAiMove(response, emit);
    }
  }

  Future<void> _onProtect(OnUnitProtectClick event, Emitter emit) async {
    final action = RequestAction(
        type: ActionType.protect,
        currentCellIndex: null,
        targetCellIndex: null);
    final response = await controller.makeAction(action);
    if (!handleResponse(response)) {
      return;
    }
    emit(state.copyWith(
      units: _warUnitsCopies,
    ));
    if (checkIsTopTeam(response.activeCell!) &&
        state.warScreenState == WarScreenState.pve) {
      await _handleAiMove(response, emit);
    }
  }

  Future<void> _onReset(OnReset event, Emitter emit) async {
    controller.reset();
    _warUnitsCopies.clear();
    _units.clear();
    _units.addAll([
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
      GameRepository.globalEmptyUnit,
    ]);

    emit(state.copyWith(
      units: _units,
      warScreenState: WarScreenState.view,
    ));
  }

  Future<void> _onPVPStarted(OnPVPStartedEvent event, Emitter emit) async {
    if (state.warScreenState != WarScreenState.view) {
      print("Битав уже начата");
      return;
    }
    /*for(var i=0; i<state.units.length; i++) {
      _warUnitsCopies.add(state.units[i].copyWith());
    }*/

    for (var element in _units) {
      _warUnitsCopies.add(element.copyWith());
    }

    var response = controller.init(_warUnitsCopies);
    if (!handleResponse(response)) {
      _warUnitsCopies.clear();
      return;
    }
    response = controller.startGame();
    if (!handleResponse(response)) {
      _warUnitsCopies.clear();
      return;
    }
    final currentActiveCell = response.activeCell;

    assert(currentActiveCell != null);

    emit(state.copyWith(
      warScreenState: WarScreenState.pvp,
      //units: List.generate(_warUnitsCopies.length, (index) => _warUnitsCopies[index].copyWith()),
      units: _warUnitsCopies,
    ));
  }

  bool handleResponse(ResponseAction responseAction) {
    print(responseAction.message);
    if (responseAction.endGame) {
      print('КОНЕЦ ИГРЫ');
      return false;
    }
    return responseAction.success;
  }

  Future<void> _onPVEStarted(OnPVEStartedEvent event, Emitter emit) async {
    if (state.warScreenState != WarScreenState.view) {
      print("Битав уже начата");
      return;
    }
    for (var element in _units) {
      _warUnitsCopies.add(element.copyWith());
    }
    var response = controller.init(_warUnitsCopies);
    if (!handleResponse(response)) {
      _warUnitsCopies.clear();
      return;
    }
    response = controller.startGame();
    if (!handleResponse(response)) {
      _warUnitsCopies.clear();
      return;
    }
    final currentActiveCell = response.activeCell;
    assert(currentActiveCell != null);

    /*final fp = FileProvider();
    await fp.init();

    final individualAiFactory = NeatFactory(
        cellsCount: cellsCount,
        cellVectorLength: cellVectorLength,
        input: inputVectorLength,
        output: actionsCount,
        version: 1);*/

    //aiController.init(_warUnitsCopies);
    // TODO Тут инициализация с файла
    /*await aiController.initFromFile(
        _warUnitsCopies,
        'default_ai_controller',
        fp,
        individualAiFactory,
      individIndex: 0,
    );*/


    emit(state.copyWith(
      warScreenState: WarScreenState.pve,
      units: _warUnitsCopies,
      positionRating: 0.0,
    ));

    if (checkIsTopTeam(currentActiveCell!)) {
      await _handleAiMove(response, emit);
      emit(state.copyWith(
        warScreenState: WarScreenState.pve,
        units: _warUnitsCopies,
      ));
    }
  }

  Future<void> _handleAiMove(ResponseAction action, Emitter emit) async {
    if (action.endGame) {
      impossibleAiActions = 0;
      return;
    }
    print('-------- Ходит AI');
    final requests = await aiController.getAction(
        action.activeCell!,
        gameController: controller,
      updateStateContext: UpdateStateContext(
        emit: emit,
        state: state,
      )
    );
    var success = false;
    emit(state.copyWith(
      units: _warUnitsCopies,
    ));
    await Future.delayed(const Duration(milliseconds: 500));
    for (var r in requests) {
      r = r.copyWith(
        context: UpdateStateContext(
        emit: emit,
        state: state,
      ));
      final response = await controller.makeAction(r);
      if (response.endGame) {
        //success = response.success;
        success = true;
        impossibleAiActions = 0;
        break;
      }
      if (response.success) {
        success = true;
        emit(state.copyWith(
          units: _warUnitsCopies,
          positionRating: r.positionRating,
        ));

        if (checkIsTopTeam(response.activeCell!)) {
          await _handleAiMove(response, emit);
          break;
        }

        break;
      } else {
        impossibleAiActions++;
        print('Невозможное действие от ИИ. Всего невозможных действий - '
            '$impossibleAiActions');
      }
    }
    emit(state.copyWith(
      units: _warUnitsCopies,
    ));
    assert(success);
  }

  Future<void> _onEVEStarted(OnEVEStartedEvent event, Emitter emit) async {
    /*for (var element in _units) {
      _warUnitsCopies.add(element.copyWith());
    }

    emit(state.copyWith(warScreenState: WarScreenState.eve));

    // /data/data/com.example.d2_ai_v2/app_flutter/2021-12-24 16:42:16.893313.json

    final gc = GeneticController(
        gameController: controller,
        aiController: aiController,
        updateStateContext: UpdateStateContext(
            emit: emit,
            state: state
        ),
        generationCount: 10000,
        maxIndividsCount: 10,
        input: neuralNetworkInputVectorLength,
        output: actionsCount,
        hidden: 100,
        layers: 10,
        units: _warUnitsCopies,
        individController: AiController(),
        fileProvider: FileProvider(),
    );

    // Инициализация с чекпоинта
    // /data/data/com.example.d2_ai_v2/app_flutter/2021-12-26 10:25:37.634445__Gen-39.json
    gc.initFromCheckpoint('2021-12-26 10:25:37.634445__Gen-39');
    print('Запуск алгоритма');
    await gc.startParallel(5, showBestBattle: true);
    print('Стоп алгоритма');*/
  }

  Future<void> _onCellTap(OnCellTapEvent event, Emitter emit) async {
    if (state.warScreenState == WarScreenState.view) {
      throw Exception();
    }

    if (!controller.gameStarted) {
      throw Exception();
    }

    final action = RequestAction(
      type: ActionType.click,
      targetCellIndex: event.cellNumber,
      currentCellIndex: null,
      context: UpdateStateContext(state: state, emit: emit),
    );

    //final List<int> lastUnitsHp = _warUnitsCopies.map((e) => e.currentHp).toList();

    final actionResponse = await controller.makeAction(action);
    if (!handleResponse(actionResponse)) {
      return;
    }

    emit(state.copyWith(units: _warUnitsCopies));

    if (checkIsTopTeam(actionResponse.activeCell!) &&
        state.warScreenState == WarScreenState.pve) {
      await _handleAiMove(actionResponse, emit);
    }
  }

  Future<void> _onCellLongTap(OnCellLongTapEvent event, Emitter emit) async {}

  Future<void> _onUnitSelected(OnUnitSelected event, Emitter emit) async {
    // todo Копировать юнитов может только РЕПОЗИТОРИЙ

    if (state.warScreenState != WarScreenState.view) {
      return;
    }
    final unit = _allUnitsMap[event.unitID];
    if (unit == null) {
      return;
    }

    _units[event.cellNumber] = unit.copyWith(
      // На поле боя юниту присваиывается уникальный id
      unitWarId: uuid.v1(),
      // Тут важно понять, что репозиторий создаёт всех юнитов один раз и
      // когда мы копируем юнита из списка всех юнитов репозитория,
      // все ссылочные типы ссылаются на одни и теже объекты (которые в репозитории)
      // нужно создать новые объекты
      attacksMap: <AttackClass, UnitAttack>{},
      attacks: <UnitAttack>[],
      unitAttack: unit.unitAttack.copyWith(),
      unitAttack2: unit.unitAttack2?.copyWith(),
    );
    emit(state.copyWith(units: _units));
  }
}

/*class UpdateStateContext {
  Emitter emit;
  GameState state;

  UpdateStateContext({required this.emit, required this.state});
}*/
