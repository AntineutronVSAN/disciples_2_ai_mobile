
import 'package:d2_ai_v2/update_state_context/update_state_context_base.dart';

class RequestAction {
  final int? currentCellIndex;
  final int? targetCellIndex;
  final UpdateStateContextBase? context;

  final double positionRating;

  final ActionType type;

  RequestAction({
    required this.type,
    required this.targetCellIndex,
    required this.currentCellIndex,
    this.context,
    this.positionRating = 0.5,
  });

  RequestAction copyWith({currentCellIndex, targetCellIndex, context, type, positionRating}) {
    return RequestAction(
      type: type ?? this.type,
      targetCellIndex: targetCellIndex ?? this.targetCellIndex,
      currentCellIndex: currentCellIndex ?? this.currentCellIndex,
      context: context ?? this.context,
        positionRating: positionRating ?? this.positionRating
    );
  }

  /// Копия действия, но без контекста обновления
  RequestAction deepCopy() {
    return RequestAction(
        type: type,
        targetCellIndex: targetCellIndex,
        currentCellIndex: currentCellIndex,
        positionRating: positionRating,
    );
  }

  @override
  String toString() {
    /*print('-------- ACTION START --------');
    print("Новое действие. Тип действия - ${type.toString().split('.').last}");
    print('Текущий юнит $currentCellIndex, цель - $targetCellIndex');
    print('-------- ACTION END --------');
    */

    var val = '';
    switch (type) {

      case ActionType.click:
        val += 'Клик на ячейку $targetCellIndex';
        break;
      case ActionType.wait:
        val += 'Ждать';
        break;
      case ActionType.protect:
        val += 'Защита';
        break;
      case ActionType.retreat:
      // TODO: Handle this case.
        break;
      case ActionType.startGame:
      // TODO: Handle this case.
        break;
      case ActionType.endGame:
      // TODO: Handle this case.
        break;
    }

    return val;
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
      success: false,
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
