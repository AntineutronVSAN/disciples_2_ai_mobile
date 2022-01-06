

import 'package:d2_ai_v2/ai_controller/ai_controller_base.dart';
import 'package:d2_ai_v2/controllers/game_controller/actions.dart';
import 'package:d2_ai_v2/controllers/game_controller/game_controller.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/optim_algorythm/base.dart';
import 'package:d2_ai_v2/optim_algorythm/individual_base.dart';
import 'package:d2_ai_v2/providers/file_provider_base.dart';


/*

Входной вектор контроллера:




*/

/*
Выходной вектор контроллера:


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

*/

class AiControllerV2 implements AiControllerBase {

  late AiAlgorithm? algorithm;
  bool inited = false;
  late List<Unit> unitsRefs;

  @override
  Future<List<RequestAction>> getAction(int currentActiveUnitCellIndex, {GameController? gameController}) {
    // TODO: implement getAction
    throw UnimplementedError();
  }

  @override
  void init(List<Unit> units, {required AiAlgorithm algorithm}) {
    this.algorithm = algorithm;
    unitsRefs = units;
    inited = true;
  }

  @override
  Future<void> initFromFile(List<Unit> units, String filePath, FileProviderBase fileProvider, IndividualFactoryBase factory, {int individIndex = 0}) async {
    await fileProvider.init();
    final checkPoint = await factory.getCheckpoint(filePath, fileProvider);
    algorithm = checkPoint.getIndividuals()[individIndex].getAlgorithm();
    unitsRefs = units;
    inited = true;
  }

  @override
  void initFromIndivid(List<Unit> units, IndividualBase ind) {
    algorithm = ind.getAlgorithm();
    unitsRefs = units;
    inited = true;
  }



}