// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nn_checkpoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NnCheckpoint _$NnCheckpointFromJson(Map json) => NnCheckpoint(
      layers: (json['layers'] as List<dynamic>).map((e) => e as int).toList(),
      unitLayers:
          (json['unitLayers'] as List<dynamic>).map((e) => e as int).toList(),
      generation: json['generation'] as int,
      individuals: (json['individuals'] as List<dynamic>)
          .map((e) =>
              GeneticIndivid.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      cellsCount: json['cellsCount'] as int,
      cellVectorLength: json['cellVectorLength'] as int,
      input: json['input'] as int,
      output: json['output'] as int,
    );

Map<String, dynamic> _$NnCheckpointToJson(NnCheckpoint instance) =>
    <String, dynamic>{
      'layers': instance.layers,
      'unitLayers': instance.unitLayers,
      'generation': instance.generation,
      'individuals': instance.individuals.map((e) => e.toJson()).toList(),
      'cellsCount': instance.cellsCount,
      'cellVectorLength': instance.cellVectorLength,
      'input': instance.input,
      'output': instance.output,
    };
