

import 'package:d2_ai_v2/utils/cell_utils.dart';

import '../../models/unit.dart';
import 'evaluation_controller.dart';

/*

1. [] - Сколько ходов проживёт команда

*/

class GlobalEvaluation {

  static const List<int> topTeamIndexes = [
    0,1,2,3,4,5
  ];
  static const List<int> topTeamFront = [
    3,4,5
  ];
  static const List<int> topTeamBack = [
    0,1,2
  ];

  static const List<int> botTeamIndexes = [
    6,7,8,9,10,11
  ];
  static const List<int> botTeamFront = [
    6,7,8
  ];
  static const List<int> botTeamBack = [
    9,10,11
  ];

  /*------------*/
  /*------1-----*/
  /*------------*/
  static const double coeff1 = 1.0;


  double teamEval(List<Unit> units, bool topTeam) {


    double res = 0.0;

    res += _howMovesTeamAliveEval(units, topTeam);


    return res;
  }

  /*------------*/
  /*------1-----*/
  /*------------*/
  double _howMovesTeamAliveEval(List<Unit> units, bool topTeam) {

    var currentTeamFrontHp = 0.0;
    var currentTeamBackHp = 0.0;

    var currentTeamAnyHeal = 0.0;
    var currentTeamAllHeal = 0.0;

    var targetTeamFrontDamage = 0.0;
    var targetTeamAnyDamage = 0.0;
    var targetTeamAllDamage = 0.0;

    for(var i = 0; i < units.length; i++) {
      final curUnit = units[i];
      final curIsTopTeam = checkIsTopTeam(i);




    }


    return 0.0;
  }

}