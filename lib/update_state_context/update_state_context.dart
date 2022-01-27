

import 'package:d2_ai_v2/bloc/states.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/update_state_context/update_state_context_base.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateStateContext implements UpdateStateContextBase {

  Emitter emit;
  GameState state;

  UpdateStateContext({required this.emit, required this.state});

  @override
  Future<void> update({int? currentGeneration, double? populationFitness, List<Unit>? units, double? posRating}) async {
    emit(state.copyWith(
      currentGeneration: currentGeneration ?? state.currentGeneration,
      populationFitness: populationFitness ?? state.populationFitness,
      units: units ?? state.units,
        positionRating: posRating ?? state.positionRating,
    ));
  }

  @override
  WarScreenState getWarScreenState() {
    return state.warScreenState;
  }
//

}