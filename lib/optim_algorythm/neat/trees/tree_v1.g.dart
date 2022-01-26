// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tree_v1.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodesInputCounter _$NodesInputCounterFromJson(Map json) => NodesInputCounter(
      currentInputs: (json['currentInputs'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      maxInputsCount: json['maxInputsCount'] as int,
    );

Map<String, dynamic> _$NodesInputCounterToJson(NodesInputCounter instance) =>
    <String, dynamic>{
      'maxInputsCount': instance.maxInputsCount,
      'currentInputs': instance.currentInputs,
    };
