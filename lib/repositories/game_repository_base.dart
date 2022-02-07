

import 'package:d2_ai_v2/models/unit.dart';



abstract class GameRepositoryBase {

  static Unit globalEmptyUnit = Unit.emptyFroRepo();

  List<Unit> getAllUnits();
  Unit? getTransformUnitByAttackId(String attckId, {bool isBig=false});

  void init();
  Unit getRandomUnit({RandomUnitOptions? options});
  Unit getCopyUnitByName(String name);
  Unit getCopyUnitById(String id);

  List<String> getAllNames();

}

class RandomUnitOptions {
  final bool frontLine;
  final bool backLine;

  RandomUnitOptions({required this.backLine, required this.frontLine});
}

