// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'neat_individ.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NeatIndivid _$NeatIndividFromJson(Map json) => NeatIndivid(
      nodes: (json['nodes'] as List<dynamic>?)
          ?.map((e) => NodeV1.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      nodesMap: (json['nodesMap'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String),
            NodeV1.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      edges: (json['edges'] as List<dynamic>?)
          ?.map((e) => EdgeV1.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      edgesMap: (json['edgesMap'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String),
            EdgeV1.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      adjacencyDictKeys: (json['adjacencyDictKeys'] as List<dynamic>?)
          ?.map((e) =>
              AdjacencyDictKey.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      adjacencyDictValues: (json['adjacencyDictValues'] as List<dynamic>?)
          ?.map((e) => EdgeV1.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      adjacencyList: (json['adjacencyList'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String),
            (e as List<dynamic>).map((e) => e as int).toList()),
      ),
      initFrom: json['initFrom'] as bool,
      inputCompleter: (json['inputCompleter'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String),
            NodesInputCounter.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      nodesStartState: (json['nodesStartState'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), e as bool),
      ),
      fitness: (json['fitness'] as num).toDouble(),
      fitnessHistory: (json['fitnessHistory'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      needCalculate: json['needCalculate'] as bool,
      input: json['input'] as int,
      output: json['output'] as int,
      cellsCount: json['cellsCount'] as int,
      cellVectorLength: json['cellVectorLength'] as int,
      version: json['version'] as int,
    );

Map<String, dynamic> _$NeatIndividToJson(NeatIndivid instance) =>
    <String, dynamic>{
      'nodes': instance.nodes?.map((e) => e.toJson()).toList(),
      'nodesMap':
          instance.nodesMap?.map((k, e) => MapEntry(k.toString(), e.toJson())),
      'edges': instance.edges?.map((e) => e.toJson()).toList(),
      'edgesMap':
          instance.edgesMap?.map((k, e) => MapEntry(k.toString(), e.toJson())),
      'adjacencyDictKeys':
          instance.adjacencyDictKeys?.map((e) => e.toJson()).toList(),
      'adjacencyDictValues':
          instance.adjacencyDictValues?.map((e) => e.toJson()).toList(),
      'adjacencyList':
          instance.adjacencyList?.map((k, e) => MapEntry(k.toString(), e)),
      'initFrom': instance.initFrom,
      'inputCompleter': instance.inputCompleter
          ?.map((k, e) => MapEntry(k.toString(), e.toJson())),
      'nodesStartState':
          instance.nodesStartState?.map((k, e) => MapEntry(k.toString(), e)),
      'fitness': instance.fitness,
      'fitnessHistory': instance.fitnessHistory,
      'needCalculate': instance.needCalculate,
      'input': instance.input,
      'output': instance.output,
      'cellsCount': instance.cellsCount,
      'cellVectorLength': instance.cellVectorLength,
      'version': instance.version,
    };
