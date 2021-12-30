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

_ParallelCalculatingRequest _$ParallelCalculatingRequestFromJson(Map json) =>
    _ParallelCalculatingRequest(
      units: (json['units'] as List<dynamic>)
          .map((e) => Unit.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      individs: (json['individs'] as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      subListIndex: json['subListIndex'] as int,
      individualIsTopTeam: json['individualIsTopTeam'] as bool,
      defaultAlgorithm:
          Map<String, dynamic>.from(json['defaultAlgorithm'] as Map),
    );

Map<String, dynamic> _$ParallelCalculatingRequestToJson(
        _ParallelCalculatingRequest instance) =>
    <String, dynamic>{
      'units': instance.units.map((e) => e.toJson()).toList(),
      'individs': instance.individs,
      'defaultAlgorithm': instance.defaultAlgorithm,
      'subListIndex': instance.subListIndex,
      'individualIsTopTeam': instance.individualIsTopTeam,
    };
