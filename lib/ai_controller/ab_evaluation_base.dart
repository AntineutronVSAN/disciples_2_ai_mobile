

import 'package:d2_ai_v2/models/unit.dart';

abstract class BaseAlphaBetaEvaluator {

  double getTeamEvaluation(List<Unit> units, bool topTeam);

}