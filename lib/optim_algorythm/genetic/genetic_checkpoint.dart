import 'package:d2_ai_v2/optim_algorythm/genetic/genetic_individ.dart';
import 'package:json_annotation/json_annotation.dart';


part 'genetic_checkpoint.g.dart';

@JsonSerializable()
class GeneticAlgorithmCheckpoint {
  final List<GeneticIndivid> individs;
  final int currentGeneration;

  final int input;
  final int output;
  final int hidden;
  final int layers;

  GeneticAlgorithmCheckpoint({
    required this.individs,
    required this.currentGeneration,
    required this.input,
    required this.output,
    required this.hidden,
    required this.layers,
  });

  factory GeneticAlgorithmCheckpoint.fromJson(Map<String, dynamic> json) => _$GeneticAlgorithmCheckpointFromJson(json);
  Map<String, dynamic> toJson() => _$GeneticAlgorithmCheckpointToJson(this);

  GeneticAlgorithmCheckpoint copyWith({
    individs,
    currentGeneration,
    input,
    output,
    hidden,
    layers,
  }) {
    return GeneticAlgorithmCheckpoint(
        individs: individs ?? this.individs,
        currentGeneration: currentGeneration ?? this.currentGeneration,
        input: input ?? this.input,
        output: output ?? this.output,
        hidden: hidden ?? this.hidden,
        layers: layers ?? this.layers
    );
  }
}
