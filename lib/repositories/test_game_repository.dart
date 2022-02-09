

import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/repositories/game_repository_base.dart';
import 'package:d2_ai_v2/test_units_factory.dart';

class TestGameRepository implements GameRepositoryBase {

  @override
  List<String> getAllNames() {
    return ['test'];
  }

  @override
  List<Unit> getAllUnits() {
    return [TestUnitsFactory.getTestUnit()];
  }

  @override
  Unit getCopyUnitById(String id) {
    return TestUnitsFactory.getTestUnit();
  }

  @override
  Unit getCopyUnitByName(String name) {
    return TestUnitsFactory.getTestUnit();
  }

  @override
  Unit getRandomUnit({RandomUnitOptions? options}) {
    return TestUnitsFactory.getTestUnit();
  }

  @override
  Unit getTransformUnitByAttackId(String attckId, {bool isBig = false}) {
    return TestUnitsFactory.getTestUnit();
  }

  @override
  Future<void> init() async {
    // TODO: implement init
  }


}