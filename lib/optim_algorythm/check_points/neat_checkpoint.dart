import 'package:d2_ai_v2/optim_algorythm/neat/individ/neat_individ.dart';
import 'package:json_annotation/json_annotation.dart';

import '../base.dart';
import '../individual_base.dart';

part 'neat_checkpoint.g.dart';


@JsonSerializable()
class NeatCheckpoint implements CheckPoint {

  final int generation;
  final List<NeatIndivid> individuals;
  final int cellsCount;
  final int cellVectorLength;
  final int input;
  final int output;

  NeatCheckpoint({
    required this.generation,
    required this.individuals,
    required this.cellsCount,
    required this.cellVectorLength,
    required this.input,
    required this.output,
  });

  factory NeatCheckpoint.fromJson(Map<String, dynamic> json) => _$NeatCheckpointFromJson(json);
  Map<String, dynamic> toJson() => _$NeatCheckpointToJson(this);

  @override
  int getGeneration() {
    return generation;
  }

  @override
  List<IndividualBase> getIndividuals() {
    return individuals;
  }

}