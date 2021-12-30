// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adjacency_dict.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdjacencyDictKey _$AdjacencyDictKeyFromJson(Map json) => AdjacencyDictKey(
      child: json['child'] as int,
      parent: json['parent'] as int,
    );

Map<String, dynamic> _$AdjacencyDictKeyToJson(AdjacencyDictKey instance) =>
    <String, dynamic>{
      'parent': instance.parent,
      'child': instance.child,
    };
