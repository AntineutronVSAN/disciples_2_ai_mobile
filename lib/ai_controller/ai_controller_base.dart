

import 'package:d2_ai_v2/controllers/game_controller/actions.dart';
import 'package:d2_ai_v2/controllers/game_controller/game_controller.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/optim_algorythm/base.dart';
import 'package:d2_ai_v2/optim_algorythm/individual_base.dart';
import 'package:d2_ai_v2/providers/file_provider_base.dart';
import 'package:d2_ai_v2/update_state_context/update_state_context_base.dart';

abstract class AiControllerBase {

  void initFromIndivid(List<Unit> units, IndividualBase ind);
  Future<void> initFromFile(
      List<Unit> units,
      String filePath,
      FileProviderBase fileProvider,
      IndividualFactoryBase factory,
      {int individIndex=0}
      );
  void init(List<Unit> units, {
    required AiAlgorithm algorithm,
  });
  Future<List<RequestAction>> getAction(
      int currentActiveUnitCellIndex, {GameController? gameController, UpdateStateContextBase? updateStateContext});
}