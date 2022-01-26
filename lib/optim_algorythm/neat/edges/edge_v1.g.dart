// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edge_v1.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EdgeV1 _$EdgeV1FromJson(Map json) => EdgeV1(
      id: json['id'] as int,
      weight: (json['weight'] as num).toDouble(),
    );

Map<String, dynamic> _$EdgeV1ToJson(EdgeV1 instance) => <String, dynamic>{
      'id': instance.id,
      'weight': instance.weight,
    };
