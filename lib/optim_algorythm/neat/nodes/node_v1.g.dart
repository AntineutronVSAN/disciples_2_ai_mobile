// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_v1.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodeV1 _$NodeV1FromJson(Map json) => NodeV1(
      id: json['id'] as int,
      activation: json['activation'] as String,
      bias: (json['bias'] as num).toDouble(),
      memorable: json['memorable'] as bool,
      memorableDepth: json['memorableDepth'] as int,
    )..lastOutputs = (json['lastOutputs'] as List<dynamic>)
        .map((e) => (e as num).toDouble())
        .toList();

Map<String, dynamic> _$NodeV1ToJson(NodeV1 instance) => <String, dynamic>{
      'id': instance.id,
      'activation': instance.activation,
      'bias': instance.bias,
      'memorable': instance.memorable,
      'lastOutputs': instance.lastOutputs,
      'memorableDepth': instance.memorableDepth,
    };
