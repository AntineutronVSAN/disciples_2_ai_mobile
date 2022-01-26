// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genetic_controller.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ParallelCalculatingResponse _$ParallelCalculatingResponseFromJson(Map json) =>
    _ParallelCalculatingResponse(
      index: json['index'] as int,
      fitness: (json['fitness'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$ParallelCalculatingResponseToJson(
        _ParallelCalculatingResponse instance) =>
    <String, dynamic>{
      'index': instance.index,
      'fitness': instance.fitness,
    };
