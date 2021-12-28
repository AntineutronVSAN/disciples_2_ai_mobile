// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genetic_checkpoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneticAlgorithmCheckpoint _$GeneticAlgorithmCheckpointFromJson(Map json) =>
    GeneticAlgorithmCheckpoint(
      individs: (json['individs'] as List<dynamic>)
          .map((e) =>
              GeneticIndivid.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      currentGeneration: json['currentGeneration'] as int,
      input: json['input'] as int,
      output: json['output'] as int,
      layers: (json['layers'] as List<dynamic>).map((e) => e as int).toList(),
      unitLayers:
          (json['unitLayers'] as List<dynamic>).map((e) => e as int).toList(),
      cellsCount: json['cellsCount'] as int,
      unitVectorLength: json['unitVectorLength'] as int,
    );

Map<String, dynamic> _$GeneticAlgorithmCheckpointToJson(
        GeneticAlgorithmCheckpoint instance) =>
    <String, dynamic>{
      'individs': instance.individs.map((e) => e.toJson()).toList(),
      'currentGeneration': instance.currentGeneration,
      'input': instance.input,
      'output': instance.output,
      'layers': instance.layers,
      'unitLayers': instance.unitLayers,
      'cellsCount': instance.cellsCount,
      'unitVectorLength': instance.unitVectorLength,
    };
