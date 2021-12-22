

import 'dart:math';

import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/utils/math_utils.dart';

class InitiativeShuffler {

  final random = Random();
  final RandomExponentialDistribution randomExponentialDistribution;

  InitiativeShuffler({required this.randomExponentialDistribution});

  /// Применить разброс инициативы, перемешать и отсортировать список юнитов
  void shuffleAndSort(List<Unit> units) {

    units.shuffle();

    final Map<String, int> _context = {};

    for (var element in units) {
      _context[element.unitWarId] = element.unitAttack.initiative +
          randomExponentialDistribution.getNextInt(9);
    }

    /*units.sort((a, b) =>
        b.unitAttack.initiative.compareTo(a.unitAttack.initiative));*/
    units.sort((a, b) =>
        _context[b.unitWarId]!.compareTo(_context[a.unitWarId]!));

  }

}

