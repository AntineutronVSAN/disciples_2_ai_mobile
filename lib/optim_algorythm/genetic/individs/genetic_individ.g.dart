// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genetic_individ.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneticIndivid _$GeneticIndividFromJson(Map json) => GeneticIndivid(
      input: json['input'] as int,
      output: json['output'] as int,
      layers: (json['layers'] as List<dynamic>).map((e) => e as int).toList(),
      unitLayers:
          (json['unitLayers'] as List<dynamic>).map((e) => e as int).toList(),
      cellsCount: json['cellsCount'] as int,
      unitVectorLength: json['unitVectorLength'] as int,
      initFrom: json['initFrom'] as bool,
      fitness: (json['fitness'] as num?)?.toDouble() ?? 0,
      weights: (json['weights'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      biases: (json['biases'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      activations: (json['activations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      unitWeights: (json['unitWeights'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      unitBiases: (json['unitBiases'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      unitActivations: (json['unitActivations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      needCalculate: json['needCalculate'] as bool? ?? true,
      fitnessHistory: (json['fitnessHistory'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      networkVersion: json['networkVersion'] as int? ?? 2,
    );

Map<String, dynamic> _$GeneticIndividToJson(GeneticIndivid instance) =>
    <String, dynamic>{
      'weights': instance.weights,
      'biases': instance.biases,
      'activations': instance.activations,
      'unitWeights': instance.unitWeights,
      'unitBiases': instance.unitBiases,
      'unitActivations': instance.unitActivations,
      'fitness': instance.fitness,
      'fitnessHistory': instance.fitnessHistory,
      'needCalculate': instance.needCalculate,
      'input': instance.input,
      'output': instance.output,
      'unitLayers': instance.unitLayers,
      'layers': instance.layers,
      'cellsCount': instance.cellsCount,
      'unitVectorLength': instance.unitVectorLength,
      'initFrom': instance.initFrom,
      'networkVersion': instance.networkVersion,
    };
