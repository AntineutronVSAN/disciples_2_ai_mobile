import 'package:d2_ai_v2/models/unit.dart';

/*

Поле боя выглядит так, цифрами показан номер ячейки:

Команда top team
#0#1#2 - Номер линии 0
#3#4#5 - Номер линии 1

Команда not team
#6#7#8 - Номер линии 2
#9#10#11 - Номер линии 3

*/

const Map<int, int> nearestMap = {
  0: 3,
  1: 4,
  2: 5,
  3: 0,
  4: 1,
  5: 2,
  6: 9,
  7: 10,
  8: 11,
  9: 6,
  10: 7,
  11: 8,
};

const Map<int, int> bigUnitFixedPos = {
  0: 3,
  1: 4,
  2: 5,
  3: 3,
  4: 4,
  5: 5,
  6: 6,
  7: 7,
  8: 8,
  9: 6,
  10: 7,
  11: 8,
};

void putUnitTo({
  required List<Unit> units,
  required Unit unit,
  required int to,
  required Unit emptyUnit}) {

  final currentUnitIsBig = unit.isBig;

  int newUnitPos;

  if (currentUnitIsBig) {
    assert(!unit.isEmpty());
    newUnitPos = bigUnitFixedPos[to]!;
    final nearestUnitPos = nearestMap[newUnitPos]!;

    units[newUnitPos] = unit;
    units[nearestUnitPos] = emptyUnit;
    return;
  }

  final nearestUnitPos = nearestMap[to]!;

  if (units[nearestUnitPos].isEmpty()) {
    units[to] = unit;
    return;
  }

  if (units[nearestUnitPos].isBig) {
    if (unit.isEmpty()) {
      return;
    }
    units[to] = unit;
    units[nearestUnitPos] = emptyUnit;
    return;
  }

  units[to] = unit;
}


/*int? canPutUnit({required List<Unit> units, required int index}) {

  final nearest = nearestMap[index]!;
  final currentIsBig = units[index].isBig;

  if (units[nearest].isEmpty()) {
    return null;
  }

  final nearestIsBig = units[nearest].isBig;

  if (currentIsBig) {

    return nearest;
  } else {
    if (nearestIsBig) {
      return nearest;
    }
    return null;
  }

}*/

bool checkCanHeal({required Unit unit,
  required int index,
  required int target,
  required List<bool> cellHasUnit,
  bool showMessage = true}) {

  final currentIsTopTeam = checkIsTopTeam(index);
  final targetIsTopTeam = checkIsTopTeam(target);

  return currentIsTopTeam == targetIsTopTeam;

}

/*bool checkCanAttack(
    {required Unit unit,
    required int index,
    required int target,
    required List<bool> cellHasUnit,
    bool showMessage = true}) {
  // TODO Refactor
  assert(cellHasUnit.length == 12);
  assert(unit.unitType == UnitType.damager);

  var topFrontLineEmpty = true;
  var botFrontLineEmpty = true;

  for (var i = 0; i < cellHasUnit.length; i++) {
    if (i >= 3 && i <= 5) {
      if (cellHasUnit[i]) {
        topFrontLineEmpty = false;
      }
    }
    if (i >= 6 && i <= 8) {
      if (cellHasUnit[i]) {
        botFrontLineEmpty = false;
      }
    }
  }

  if (checkIsTopTeam(index)) {
    if (target >= 0 && target <= 5) {
      CustomPrinter.printVal('Юнит не может атаковать своего');
      return false;
    }
    switch (unit.targetsCount) {
      case TargetsCount.one:
        return _findNearestTarget(
          unit: unit,
          index: index,
          target: target,
          cellHasUnit: cellHasUnit,
          direction: true,
          topFrontEmpty: topFrontLineEmpty,
          botFrontEmpty: botFrontLineEmpty,
          currentRecursionLevel: 0,
        );

      case TargetsCount.all:
        return true;
      case TargetsCount.any:
        return true;
    }
  } else {
    if (target >= 6 && target <= 11) {
      CustomPrinter.printVal('Юнит не может атаковать своего');
      return false;
    }
    switch (unit.targetsCount) {
      case TargetsCount.one:

        return _findNearestTarget(
          unit: unit,
          index: index,
          target: target,
          cellHasUnit: cellHasUnit,
          direction: false,
          topFrontEmpty: topFrontLineEmpty,
          botFrontEmpty: botFrontLineEmpty,
          currentRecursionLevel: 0,
        );

      case TargetsCount.all:
        return true;
      case TargetsCount.any:
        return true;
    }
  }
}*/

const List<bool> topTeamChecker = [
  true,
  true,
  true,
  true,
  true,
  true,
  false,
  false,
  false,
  false,
  false,
  false,
];

bool checkIsTopTeam(int index) {
  return topTeamChecker[index];
  /*if (index <= 5) {
    return true;
  } else if (index > 5 && index <= 11) {
    return false;
  }*/
  throw Exception();
}

bool findNearestTarget({
  required Unit unit,
  required int index,
  required int target,
  required List<bool> cellHasUnit,
  required bool direction, // true -> top-bot
  required bool topFrontEmpty,
  required bool botFrontEmpty,
  required int currentRecursionLevel,
}) {

  currentRecursionLevel += 1;
  if (currentRecursionLevel > 1000) {
    throw Exception();
  }
  assert(index >= 0 && index <= 11);

  var currentIndex = index;
  int directionIncrement = direction ? 3 : -3;

  currentIndex += directionIncrement;
  var currentLineNumber = getLineNumber(currentIndex);

  if (direction ? checkIsTopTeam(currentIndex) : !checkIsTopTeam(currentIndex)) {
    // Попали на линию своих милишников
    if (direction ? !topFrontEmpty : !botFrontEmpty) {
      return false;
    }
    // Фронт пустой, идём дальше
    return findNearestTarget(
      unit: unit,
      index: currentIndex,
      target: target,
      cellHasUnit: cellHasUnit,
      direction: direction,
      topFrontEmpty: topFrontEmpty,
      botFrontEmpty: botFrontEmpty,
      currentRecursionLevel: currentRecursionLevel,
    );
  }
  if (currentIndex == target) {
    return true;
  }
  // Если фронт чужой стороны пустой, идём дальше
  // также нельзя выходить за пределы
  if ((direction ? botFrontEmpty : topFrontEmpty) &&
      ((currentIndex + directionIncrement) >= 0 &&
          (currentIndex + directionIncrement) <= 11)) {
    return findNearestTarget(
      unit: unit,
      index: currentIndex,
      target: target,
      cellHasUnit: cellHasUnit,
      direction: direction,
      topFrontEmpty: topFrontEmpty,
      botFrontEmpty: botFrontEmpty,
      currentRecursionLevel: currentRecursionLevel,
    );
  }
  // В стороны допускается только один шаг
  var leftIndex = currentIndex - 1;
  bool useLeftIndex = true;
  var rightIndex = currentIndex + 1;
  bool useRightIndex = true;

  final leftIndexLine = getLineNumber(leftIndex);
  final rightIndexLine = getLineNumber(rightIndex);

  // -1 Вернёт, если выпали за допустимые диапазоны
  // Если переход на следующую линию, то индекс не считается
  useLeftIndex = leftIndexLine != -1 && leftIndexLine == currentLineNumber;
  useRightIndex = rightIndexLine != -1 && rightIndexLine == currentLineNumber;

  // Хоть куда-то должно быть можно пойти дальше
  assert(useLeftIndex || useRightIndex);

  // Если живой юнит не найден, тогда считаем, что он далеко и до него можно добраться
  bool unitFound = false;

  if (useLeftIndex && !unitFound) {
    unitFound = cellHasUnit[leftIndex];
  }
  if (useRightIndex && !unitFound) {
    unitFound = cellHasUnit[rightIndex];
  }

  // Не забываем смотреть наличие юнита в текущей ячейке
  if (!unitFound) {
    unitFound = cellHasUnit[currentIndex];
  }
  if (!unitFound) {
    return currentLineNumber == getLineNumber(target);
  }
  return ((leftIndex == target) && useLeftIndex) ||
      ((rightIndex == target) && useRightIndex);
}


const List<int> cellIndexLineNumber = [
  0,0,0,1,1,1,2,2,2,3,3,3
];

int getLineNumber(int index) {
  if (index < 0 || index > 11) return -1;
  return cellIndexLineNumber[index];
  /*if (index < 0) {
    return -1;
  }
  int currentLineNumber = 0;

  while(true) {

    if ((index >= currentLineNumber * 3)
        && (index <= currentLineNumber * 3 + 2)
    ) {
      return currentLineNumber;
    }
    currentLineNumber += 1;
    if (currentLineNumber > 3) {
      return -1;
    }
    if (currentLineNumber > 100) {
      throw Exception();
    }
  }*/

}
