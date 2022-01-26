

import 'package:d2_ai_v2/optim_algorythm/genetic/individs/genetic_individ.dart';

import '../base.dart';
import '../individual_base.dart';
import 'package:json_annotation/json_annotation.dart';

part 'nn_checkpoint.g.dart';


@JsonSerializable()
class NnCheckpoint implements CheckPoint {
  
  final List<int> layers;
  final List<int> unitLayers;
  final int generation;
  final List<GeneticIndivid> individuals;
  final int cellsCount;
  final int cellVectorLength;
  final int input;
  final int output;

  NnCheckpoint({
    required this.layers,
    required this.unitLayers,
    required this.generation,
    required this.individuals,
    required this.cellsCount,
    required this.cellVectorLength,
    required this.input,
    required this.output,
  });

  factory NnCheckpoint.fromJson(Map<String, dynamic> json) => _$NnCheckpointFromJson(json);
  Map<String, dynamic> toJson() => _$NnCheckpointToJson(this);

  @override
  int getGeneration() {
    return generation;
  }

  @override
  List<IndividualBase> getIndividuals() {
    return individuals;
  }
  
}