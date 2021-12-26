// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genetic_worker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneticWorkerMessage _$GeneticWorkerMessageFromJson(Map json) =>
    GeneticWorkerMessage(
      units: (json['units'] as List<dynamic>)
          .map((e) => Unit.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      input: json['input'] as int,
      output: json['output'] as int,
      hidden: json['hidden'] as int,
      layers: json['layers'] as int,
      individs: (json['individs'] as List<dynamic>)
          .map((e) =>
              GeneticIndivid.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$GeneticWorkerMessageToJson(
        GeneticWorkerMessage instance) =>
    <String, dynamic>{
      'units': instance.units.map((e) => e.toJson()).toList(),
      'individs': instance.individs.map((e) => e.toJson()).toList(),
      'input': instance.input,
      'output': instance.output,
      'hidden': instance.hidden,
      'layers': instance.layers,
    };

GeneticWorkerResponse _$GeneticWorkerResponseFromJson(Map json) =>
    GeneticWorkerResponse(
      fitness: (json['fitness'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$GeneticWorkerResponseToJson(
        GeneticWorkerResponse instance) =>
    <String, dynamic>{
      'fitness': instance.fitness,
    };
