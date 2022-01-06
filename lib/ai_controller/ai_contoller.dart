/*


Выходной вектор нейронной сети:


 - Вероятность клика на ячейку 0
 - Вероятность клика на ячейку 1
 - Вероятность клика на ячейку 2
  - Вероятность клика на ячейку 3
 - Вероятность клика на ячейку 4
 - Вероятность клика на ячейку 5

 - Вероятность клика на ячейку 6
 - Вероятность клика на ячейку 7
 - Вероятность клика на ячейку 8
 - Вероятность клика на ячейку 9
 - Вероятность клика на ячейку 10
 - Вероятность клика на ячейку 11

 - Защита
 - Ждать

####
#### Первый варианта входного вектора
####

Ну и самое вкусное, входной вектор в неронку:
Все значения должны быть отмасштабированы от 0 до 1
Для простоты, пока считаем, что AI играет за топовую команду
Путой или мёртвый юнит - все нули

[
  // Ячейка 0
  0.0, - Ходит ли ячейка,

  // Юнит 15
  0.0, - Защищена ли ячейка,
  0.0, - Ждёт ли ячейка,
  0.0, - Ячейка пустая
  0.0, - Ячейка мертва
  0.5, - Текущее ХП
  0.5, - Текущий армор
  0.0 - Двойная атака
  0.0, - Висит ли ожёг
  0.0, - Периодический урон
  0.0, - Висит ли мороз
  0.0, - Периодический урон
  0.0, - Висит ли яд
  0.0, - Периодический урон
  0.0 - Паралич
  0.0 - Окаменение

  // Первая атака юнита 37
  *0.0 - Инициатива
    0.0 - Урон
    0.0 - Хил
    0.0 - Точность
    0.0 - Длительная ли атака
    0.0 - Уровень атака 1
    0.0 - Уровень атака 2
    0.0 - Уровень атака 3
    0.0 - Уровень атака 4

    0.0 - Число целей 1
    0.0 - Число целей любая
    0.0 - Число целей все

    0.0 - Класс атаки 1
    0.0 - Класс атаки 2
    ...
    0.0 - Класс атаки 25
  // Вторая атака 37
  ...


]


TODO:
* Заменить точность и урон на математическое ожидание

*/

import 'package:d2_ai_v2/controllers/game_controller/actions.dart';
import 'package:d2_ai_v2/controllers/game_controller/game_controller.dart';
import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/optim_algorythm/base.dart';
import 'package:d2_ai_v2/optim_algorythm/individual_base.dart';
import 'package:d2_ai_v2/providers/file_provider_base.dart';

import 'ai_controller_base.dart';


class AiController implements AiControllerBase {

  /// В основе контроллера ИИ лежит алгоритм. Сущность алгоритма - интерфейс
  /// Алгоритм может быть различным. В частность, нейронной сетью или алгоритмом
  /// neat
  late AiAlgorithm? algorithm;

  bool inited = false;

  /// Ссылки на юнитов!
  /// Игровые механики изменяют этих юнитов
  late List<Unit> unitsRefs;


  @override
  void initFromIndivid(List<Unit> units, IndividualBase ind) {
    algorithm = ind.getAlgorithm();
    unitsRefs = units;
    inited = true;
  }


  @override
  Future<void> initFromFile(
      List<Unit> units,
      String filePath,
      FileProviderBase fileProvider,
      IndividualFactoryBase factory,
      {int individIndex=0}
      ) async {
    //final fileProvider = FileProvider(); // todo
    await fileProvider.init();
    //final checkPoint = NeatCheckpoint.fromJson(await fileProvider.getDataByFileName(filePath));
    final checkPoint = await factory.getCheckpoint(filePath, fileProvider);
    algorithm = checkPoint.getIndividuals()[individIndex].getAlgorithm();
    unitsRefs = units;
    inited = true;
  }

  @override
  void init(List<Unit> units, {
    required AiAlgorithm algorithm,
  }) {
    this.algorithm = algorithm;
    unitsRefs = units;
    inited = true;
  }

  /// Запросить действия у контроллера AI
  /// Вернёт список действий, отсортированный в порядке
  /// убывания увренности. Тоесть вызывающий метод, в случае неуспеха
  /// лучшего действия, должен применить следующее
  @override
  Future<List<RequestAction>> getAction(int currentActiveUnitCellIndex, {GameController? gameController}) async {
    if (!inited) {
      throw Exception();
    }

    final List<RequestAction> result = [];

    final gameVector = _units2Vector(currentActiveUnitCellIndex);

    // Отправляется вектор в нейронку
    final outputVector = algorithm!.forward(gameVector);

    List<_NeuralRequestAction> nnActions = [];

    for(var i=0; i<outputVector.length; i++) {
      nnActions.add(
          _NeuralRequestAction(
              value: outputVector[i],
              index: i)
      );
    }
    nnActions.sort((a, b) => b.value.compareTo(a.value));

    //int index = 0;
    for(var act in nnActions) {
      /*
      0 - Вероятность ударить ячейку 0
      1 - Вероятность ударить ячейку 1
      2 - Вероятность ударить ячейку 2
      3 - Вероятность ударить ячейку 3
      4 - Вероятность ударить ячейку 4
      5 - Вероятность ударить ячейку 5
      ...
      11 - Вероятность ударить ячейку 11
      12 - Защита
      13 - Ждать*/

      if (act.index > 11) {

        if (act.index == 12) {
          result.add(RequestAction(
            type: ActionType.protect,
            targetCellIndex: null,
            currentCellIndex: currentActiveUnitCellIndex,
          ));
        } else if (act.index == 13) {
          result.add(RequestAction(
            type: ActionType.wait,
            targetCellIndex: null,
            currentCellIndex: currentActiveUnitCellIndex,
          ));
        } else {
          throw Exception();
        }

      } else {
        result.add(RequestAction(
          type: ActionType.click,
          targetCellIndex: act.index,
          currentCellIndex: currentActiveUnitCellIndex,
        ));
      }

      //index++;
    }
    return result;
  }

  List<double> _units2Vector(int currentActiveUnitCellIndex) {
    final List<double> resultList = [];
    var index = 0;
    assert(unitsRefs.length == 12);
    for(var unit in unitsRefs) {
      List<double> currentUnitVector = [];
      if (currentActiveUnitCellIndex == index) {
        currentUnitVector.add(1.0);
      } else {
        currentUnitVector.add(0.0);
      }

      currentUnitVector.addAll(_vectorFromUnit(unit));
      currentUnitVector.addAll(_vectorFromAttack(unit.unitAttack));
      currentUnitVector.addAll(_vectorFromAttack(unit.unitAttack2));

      index++;
      resultList.addAll(currentUnitVector);
    }
    return resultList;
  }

}


List<double> _vectorFromAttack(UnitAttack? atck) {
  /*0.0 - Инициатива
    0.0 - Урон
    0.0 - Хил
    0.0 - Точность
    0.0 - Длительная ли атака
    0.0 - Уровень атака 1
    0.0 - Уровень атака 2
    0.0 - Уровень атака 3
    0.0 - Уровень атака 4

    0.0 - Число целей 1
    0.0 - Число целей любая
    0.0 - Число целей все

    0.0 - Класс атаки 1
    0.0 - Класс атаки 2
    ...
    0.0 - Класс атаки 25*/

  List<double> result = [];

  if (atck == null) {
    return List.generate(37, (index) => 0.0);
  }

  result.add(atck.initiative / 90.0);
  result.add(atck.damage / 999.0);
  result.add(atck.heal / 999.0);
  result.add(atck.power / 100.0);
  result.add(atck.infinite ? 1.0 : 0.0);

  List<double> atckLevels = [0.0, 0.0, 0.0, 0.0, 0.0];
  atckLevels[atck.level] = 1.0;
  result.addAll(atckLevels.sublist(1));

  switch(atck.targetsCount) {

    case TargetsCount.one:
      result.add(1.0);
      result.add(0.0);
      result.add(0.0);
      break;
    case TargetsCount.all:
      result.add(0.0);
      result.add(0.0);
      result.add(1.0);
      break;
    case TargetsCount.any:
      result.add(0.0);
      result.add(1.0);
      result.add(0.0);
      break;
  }

  // todo
  List<double> attackClasses = List.generate(25, (index) => 0.0);
  final atckIndex = atck.attackClass.index;
  attackClasses[atckIndex] = 1.0;
  result.addAll(attackClasses);
  //result.add(atckIndex / 25.0);
  return result;
}

List<double> _vectorFromUnit(Unit unit) {
  /*
      0.0, - Защищена ли ячейка,
      0.0, - Ждёт ли ячейка,
      0.0, - Ячейка пустая
      0.0, - Ячейка мертва
      0.5, - Текущее ХП
      0.5, - Текущий армор
      0.0 - Двойная атака
      0.0, - Висит ли ожёг
      0.0, - Периодический урон
      0.0, - Висит ли мороз
      0.0, - Периодический урон
      0.0, - Висит ли яд
      0.0, - Периодический урон
      0.0 - Паралич
      0.0 - Окаменение
  */

  List<double> result = [];

  if (unit.isDead) {
    return List.generate(15, (index) {
      if (index == 3) {
        return 1.0;
      }
      return 0.0;
    });
  }
  if (unit.isEmpty()) {
    return List.generate(15, (index) {
      if (index == 2) {
        return 1.0;
      }
      return 0.0;
    });
  }

  result.add(unit.isProtected ? 1.0 : 0.0);
  result.add(unit.isWaiting ? 1.0 : 0.0);
  result.add(0.0);
  result.add(0.0);

  result.add(unit.currentHp / 9999.0);
  result.add(unit.armor / 90.0);

  result.add(unit.isDoubleAttack ? 1.0 : 0.0);

  if (unit.attacksMap.containsKey(AttackClass.L_BLISTER)) {
    final atck = unit.attacksMap[AttackClass.L_BLISTER]!;
    result.add(1.0);
    result.add(atck.damage / 999.0);
  } else {
    result.add(0.0);
    result.add(0.0);
  }
  if (unit.attacksMap.containsKey(AttackClass.L_FROSTBITE)) {
    final atck = unit.attacksMap[AttackClass.L_FROSTBITE]!;
    result.add(1.0);
    result.add(atck.damage / 999.0);
  } else {
    result.add(0.0);
    result.add(0.0);
  }
  if (unit.attacksMap.containsKey(AttackClass.L_POISON)) {
    final atck = unit.attacksMap[AttackClass.L_POISON]!;
    result.add(1.0);
    result.add(atck.damage / 999.0);
  } else {
    result.add(0.0);
    result.add(0.0);
  }

  result.add(unit.paralyzed ? 1.0 : 0.0);
  result.add(unit.petrified ? 1.0 : 0.0);


  return result;
}


class _NeuralRequestAction {
  final int index;
  final double value;

  _NeuralRequestAction({required this.index, required this.value});
}