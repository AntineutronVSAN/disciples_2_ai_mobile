

import 'package:d2_ai_v2/controllers/game_controller/actions.dart';
import 'package:d2_ai_v2/controllers/game_controller/game_controller.dart';
import 'package:d2_ai_v2/controllers/game_controller/sync_game_controller.dart';

String getABPruningNodeKey({
  required GameController controller,
  required RequestAction action,
}) {

  String res = '';

  res += controller.currentActiveCellIndex.toString();
  res += '_';

  for(var u in controller.units) {
    res += u.unitWarId;
    res += '_';
    res += u.currentHp.toString();
    res += '_';
  }

  for(var u in controller.unitsQueue!) {
    res += u.unitWarId;
    res += '_';
  }

  res += action.type.toString();
  res += '_';
  res += action.targetCellIndex.toString();
  res += '_';

  return res;
}

String getABPruningNodeKeySync({
  required GameController controller,
  required RequestAction action,
}) {

  String res = '';

  res += controller.currentActiveCellIndex.toString();
  res += '_';

  for(var u in controller.units) {
    res += u.unitWarId;
    res += '_';
    res += u.currentHp.toString();
    res += '_';
  }

  res += action.type.toString();
  res += action.targetCellIndex.toString();

  return res;
}