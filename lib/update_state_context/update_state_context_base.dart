

import 'package:d2_ai_v2/bloc/states.dart';
import 'package:d2_ai_v2/models/unit.dart';

abstract class UpdateStateContextBase {
  Future<void> update({
    int? currentGeneration,
    double? populationFitness,
    List<Unit>? units,
    double? posRating,
    int? nodesPerSecond,
  });

  WarScreenState getWarScreenState();
}