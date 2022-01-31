

import 'dart:math';

import 'package:d2_ai_v2/controllers/game_controller/roll_config.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/utils/math_utils.dart';

class InitiativeShuffler {

  final random = Random();
  final RandomExponentialDistribution randomExponentialDistribution;

  InitiativeShuffler({required this.randomExponentialDistribution});

  /// Применить разброс инициативы, перемешать и отсортировать список юнитов
  void shuffleAndSort(List<Unit> units, {
    required RollConfig rollConfig
}) {

    units.shuffle();

    final Map<String, int> _context = {};

    var index = 0;
    for (var element in units) {
      if (index >= 0 && index <= 5) {
        // Топ команда
        if (rollConfig.topTeamMaxIni) {
          _context[element.unitConstParams.unitWarId] = element.unitAttack.initiative + 9;
        } else {
          _context[element.unitConstParams.unitWarId] = element.unitAttack.initiative +
              randomExponentialDistribution.getNextInt(9);
        }

      } else if (index >= 6 && index <= 11) {
        // Бот
        if (rollConfig.bottomTeamMaxIni) {
          _context[element.unitConstParams.unitWarId] = element.unitAttack.initiative + 9;
        } else {
          _context[element.unitConstParams.unitWarId] = element.unitAttack.initiative +
              randomExponentialDistribution.getNextInt(9);
        }

      } else {
        throw Exception();
      }
      index++;
    }

    units.sort((a, b) =>
        _context[b.unitConstParams.unitWarId]!.compareTo(_context[a.unitConstParams.unitWarId]!));

  }

}

