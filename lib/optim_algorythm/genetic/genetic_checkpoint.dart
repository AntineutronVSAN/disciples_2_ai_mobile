import 'package:d2_ai_v2/optim_algorythm/genetic/individs/genetic_individ.dart';
import 'package:json_annotation/json_annotation.dart';

import 'individs/genetic_individ_base.dart';


part 'genetic_checkpoint.g.dart';

@JsonSerializable()
class GeneticAlgorithmCheckpoint {
  final List<GeneticIndivid> individs;
  final int currentGeneration;

  final int input;
  final int output;

  final List<int> layers;
  final List<int> unitLayers;

  final int cellsCount;
  final int unitVectorLength;

  GeneticAlgorithmCheckpoint({
    required this.individs,
    required this.currentGeneration,
    required this.input,
    required this.output,

    required this.layers,
    required this.unitLayers,

    required this.cellsCount,
    required this.unitVectorLength,
  });

  factory GeneticAlgorithmCheckpoint.fromJson(Map<String, dynamic> json) => _$GeneticAlgorithmCheckpointFromJson(json);
  Map<String, dynamic> toJson() => _$GeneticAlgorithmCheckpointToJson(this);

  GeneticAlgorithmCheckpoint copyWith({
    individs,
    currentGeneration,
    input,
    output,

    layers,
    unitLayers,

    cellsCount,
    unitVectorLength
  }) {
    return GeneticAlgorithmCheckpoint(
        individs: individs ?? this.individs,
        currentGeneration: currentGeneration ?? this.currentGeneration,
        input: input ?? this.input,
        output: output ?? this.output,
        layers: layers ?? this.layers,
        cellsCount: cellsCount ?? this.cellsCount,
        unitLayers: unitLayers ?? this.unitLayers,
        unitVectorLength: unitVectorLength ?? this.unitVectorLength
    );
  }
}
