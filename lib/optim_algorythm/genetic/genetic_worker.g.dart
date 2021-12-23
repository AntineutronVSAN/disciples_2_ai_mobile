// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genetic_worker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneticWorkerMessage _$GeneticWorkerMessageFromJson(
        Map<String, dynamic> json) =>
    GeneticWorkerMessage(
      units: (json['units'] as List<dynamic>)
          .map((e) => Unit.fromJson(e as Map<String, dynamic>))
          .toList(),
      input: json['input'] as int,
      output: json['output'] as int,
      hidden: json['hidden'] as int,
      layers: json['layers'] as int,
      individs: (json['individs'] as List<dynamic>)
          .map((e) => GeneticIndivid.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GeneticWorkerMessageToJson(
        GeneticWorkerMessage instance) =>
    <String, dynamic>{
      'units': instance.units,
      'individs': instance.individs,
      'input': instance.input,
      'output': instance.output,
      'hidden': instance.hidden,
      'layers': instance.layers,
    };

GeneticWorkerResponse _$GeneticWorkerResponseFromJson(
        Map<String, dynamic> json) =>
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
