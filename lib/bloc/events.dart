

abstract class GameEvent {

}

class InitialEvent extends GameEvent {

}

class OnPVPStartedEvent extends GameEvent {

}

class OnPVEStartedEvent extends GameEvent {

}

class OnEVEStartedEvent extends GameEvent {

}

class OnUnitsChangedEvent extends GameEvent {

}

class OnCellTapEvent extends GameEvent {
  final int cellNumber;
  OnCellTapEvent({required this.cellNumber});
}

class OnCellLongTapEvent extends GameEvent {
  final int cellNumber;
  OnCellLongTapEvent({required this.cellNumber});
}

class OnUnitSelected extends GameEvent {
  final String unitID;
  final int cellNumber;
  OnUnitSelected({required this.unitID, required this.cellNumber});
}

class OnUnitProtectClick extends GameEvent {

}

class OnUnitWaitClick extends GameEvent {

}

class OnReset extends GameEvent {

}

class OnRetreat extends GameEvent {}

class OnUnitsListFilters extends GameEvent {

  final String unitName;

  OnUnitsListFilters({required this.unitName});
}

class OnUnitsLoad extends GameEvent {}