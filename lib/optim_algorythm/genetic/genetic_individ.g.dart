// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genetic_individ.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneticIndivid _$GeneticIndividFromJson(Map json) => GeneticIndivid(
      input: json['input'] as int,
      output: json['output'] as int,
      hidden: json['hidden'] as int,
      layers: json['layers'] as int,
      fitness: (json['fitness'] as num?)?.toDouble() ?? 0,
      weights: (json['weights'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      biases: (json['biases'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      needCalculate: json['needCalculate'] as bool? ?? true,
      nnInited: json['nnInited'] as bool? ?? false,
      activations: (json['activations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      fitnessHistory: (json['fitnessHistory'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$GeneticIndividToJson(GeneticIndivid instance) =>
    <String, dynamic>{
      'weights': instance.weights,
      'biases': instance.biases,
      'activations': instance.activations,
      'fitness': instance.fitness,
      'fitnessHistory': instance.fitnessHistory,
      'needCalculate': instance.needCalculate,
      'nnInited': instance.nnInited,
      'input': instance.input,
      'output': instance.output,
      'hidden': instance.hidden,
      'layers': instance.layers,
    };
