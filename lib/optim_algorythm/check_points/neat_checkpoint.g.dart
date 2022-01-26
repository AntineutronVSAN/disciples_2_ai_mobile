// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'neat_checkpoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NeatCheckpoint _$NeatCheckpointFromJson(Map json) => NeatCheckpoint(
      generation: json['generation'] as int,
      individuals: (json['individuals'] as List<dynamic>)
          .map((e) => NeatIndivid.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      cellsCount: json['cellsCount'] as int,
      cellVectorLength: json['cellVectorLength'] as int,
      input: json['input'] as int,
      output: json['output'] as int,
    );

Map<String, dynamic> _$NeatCheckpointToJson(NeatCheckpoint instance) =>
    <String, dynamic>{
      'generation': instance.generation,
      'individuals': instance.individuals.map((e) => e.toJson()).toList(),
      'cellsCount': instance.cellsCount,
      'cellVectorLength': instance.cellVectorLength,
      'input': instance.input,
      'output': instance.output,
    };
