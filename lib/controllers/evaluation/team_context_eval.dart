

import 'package:d2_ai_v2/controllers/attack_controller/attack_controller.dart';

import '../../models/unit.dart';
import 'evaluation_controller.dart';

/*

1 [x] - Если юнит дальник и жив мили ряд, его атака ценнее

*/


class TeamContextEval {

  /*------------*/
  /*------1-----*/
  /*------------*/
  static const double notMiliUnitAndHasFrontCoeff = 2.0;
  final List<int> unitIndexes = [-1, -1, -1];
  final List<int> topMiliIndexes = [3,4,5];
  final List<int> botMiliIndexes = [6,7,8];


  void teamContextEval(int index, List<Unit> units, GameEvaluation eval, bool isTopTeam) {
    double resultAttackCoeffOur = 1.0;
    double resultAttackCoeffEnemy = 1.0;
    final coeff1 = _getNotMiliEvalCoeff(index, units, eval, isTopTeam);
    resultAttackCoeffOur *= coeff1;

    eval.enemyTeamContextAttackEval = resultAttackCoeffEnemy;
    eval.ourTeamContextAttackEval = resultAttackCoeffOur;
  }

  /*------------*/
  /*------1-----*/
  /*------------*/
  double _getNotMiliEvalCoeff(int index, List<Unit> units, GameEvaluation eval, bool isTopTeam) {
    double result = 1.0;
    if (isTopTeam) {
      if (topMiliIndexes.contains(index)) {
        return result;
      }
      unitIndexes[0] = topMiliIndexes[0];
      unitIndexes[1] = topMiliIndexes[1];
      unitIndexes[2] = topMiliIndexes[2];
    } else {
      if (botMiliIndexes.contains(index)) {
        return result;
      }
      unitIndexes[0] = botMiliIndexes[0];
      unitIndexes[1] = botMiliIndexes[1];
      unitIndexes[2] = botMiliIndexes[2];
    }
    // Если юнит прикрыт милишниками, то его атака более ценная
    if (!AttackController.isMiliUnit(units[index])) {
      bool hasMili = false;
      for(var i in unitIndexes) {
        final curUnit = units[i];
        if (curUnit.isDead || curUnit.isEmpty()) {
          continue;
        }
        hasMili = true;
      }
      if (hasMili) {
        result *= 2.0;
      }
    }
    return result;
  }
}