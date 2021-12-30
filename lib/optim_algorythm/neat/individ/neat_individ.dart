import 'dart:math';

import 'package:d2_ai_v2/optim_algorythm/neat/edges/edge_v1.dart';
import 'package:d2_ai_v2/optim_algorythm/neat/nodes/node_v1.dart';
import 'package:d2_ai_v2/optim_algorythm/neat/trees/tree_v1.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:d2_ai_v2/optim_algorythm/base.dart';
import 'package:d2_ai_v2/optim_algorythm/individual_base.dart';

import '../adjacency_dict.dart';
import '../edge_base.dart';
import '../game_tree_base.dart';

part 'neat_individ.g.dart';

@JsonSerializable()
class NeatIndivid implements IndividualBase {


  List<NodeV1>? nodes;
  Map<int, NodeV1>? nodesMap;
  List<EdgeV1>? edges;
  Map<int, EdgeV1>? edgesMap;
  // json Сериалайзер ругается на ключ-класс. Разделим итемы на два списка
  //final Map<AdjacencyDictKey, EdgeV1> adjacencyDict;
  List<AdjacencyDictKey>? adjacencyDictKeys;
  List<EdgeV1>? adjacencyDictValues;
  Map<int, List<int>>? adjacencyList;
  bool initFrom;
  Map<int, NodesInputCounter>? inputCompleter;
  Map<int, bool>? nodesStartState;

  double fitness;
  List<double> fitnessHistory;
  bool needCalculate;

  @JsonKey(ignore: true)
  GameTreeBase? tree;
  @JsonKey(ignore: true)
  Map<AdjacencyDictKey, EdgeV1>? adjacencyDict;

  final int input;
  final int output;
  final int cellsCount;
  final int cellVectorLength;
  final random = Random();
  final int version;

  NeatIndivid({
    this.nodes,
    this.nodesMap,
    this.edges,
    this.edgesMap,
    this.adjacencyDict,
    this.adjacencyDictKeys,
    this.adjacencyDictValues,
    this.adjacencyList,
    required this.initFrom,
    this.inputCompleter,
    this.nodesStartState,
    required this.fitness,
    required this.fitnessHistory,
    required this.needCalculate,
    required this.input,
    required this.output,
    required this.cellsCount,
    required this.cellVectorLength,
    required this.version,
  }) {

    if (initFrom) {
      assert(
        nodes != null &&
        nodesMap != null &&
        edges != null &&
        edgesMap != null &&
        adjacencyDictKeys != null &&
        adjacencyDictValues != null &&
        adjacencyList != null &&
        inputCompleter != null &&
        nodesStartState != null
      );
      //adjacencyDict = Map.fromIterables(adjacencyDictKeys!, adjacencyDictValues!);
      if (adjacencyDict != null) {
        adjacencyDict!.clear();
        assert(adjacencyDictKeys!.length == adjacencyDictValues!.length);
        for(var i=0; i<adjacencyDictKeys!.length; i++) {
          adjacencyDict![adjacencyDictKeys![i]] = adjacencyDictValues![i];
        }
      } else {
        adjacencyDict = Map.fromIterables(adjacencyDictKeys!, adjacencyDictValues!);
      }

      tree = TreeV1(
          input: input,
          output: output,
          nodes: nodes!,
          nodesMap: nodesMap!,
          edges: edges!,
          edgesMap: edgesMap!,
          adjacencyDict: adjacencyDict!,
          initFrom: initFrom,
          adjacencyList: adjacencyList!,
          nodesStartState: nodesStartState!,
          inputCompleter: inputCompleter!);
    } else {
      adjacencyDictKeys = [];
      adjacencyDictValues = [];
      nodes = [];
      nodesMap = {};
      edges = [];
      edgesMap = {};
      adjacencyList = {};
      nodesStartState = {};
      inputCompleter = {};
      adjacencyDict = {};
      tree = TreeV1(
          input: input,
          output: output,
          nodes: nodes!,
          nodesMap: nodesMap!,
          edges: edges!,
          edgesMap: edgesMap!,
          adjacencyDict: adjacencyDict!,
          initFrom: initFrom,
          adjacencyList: adjacencyList!,
          nodesStartState: nodesStartState!,
          inputCompleter: inputCompleter!);
    }

    assertsTest();
  }

  void assertsTest() {
    assert(edges!.length == adjacencyDict!.length);
    assert(edges!.length == adjacencyDictKeys!.length);
    assert(edges!.length == adjacencyDictValues!.length);
  }
  /*@override
  IndividualBase copyWith({
    nodes,
    nodesMap,
    edges,
    edgesMap,
    adjacencyDict,
    adjacencyList,
    initFrom,
    inputCompleter,
    nodesStartState,
    fitness,
    fitnessHistory,
    needCalculate,
    input,
    output,
    cellsCount,
    cellVectorLength,
    version,
    adjacencyDictKeys,
    adjacencyDictValues
  }) {

    return NeatIndivid(
      adjacencyDict: adjacencyDict ?? this.adjacencyDict,
        nodes: nodes ?? this.nodes,
        nodesMap: nodesMap ?? this.nodesMap,
        edges: edges ?? this.edges,
        edgesMap: edgesMap ?? this.edgesMap,

        adjacencyDictKeys: adjacencyDictKeys ?? this.adjacencyDictKeys,
        adjacencyDictValues: adjacencyDictValues ?? this.adjacencyDictValues,

        adjacencyList: adjacencyList ?? this.adjacencyList,
        initFrom: initFrom ?? this.initFrom,
        inputCompleter: inputCompleter ?? this.inputCompleter,
        nodesStartState: nodesStartState ?? this.nodesStartState,
        fitness: fitness ?? this.fitness,
        fitnessHistory: fitnessHistory ?? this.fitnessHistory,
        needCalculate: needCalculate ?? this.needCalculate,
        input: input ?? this.input,
        output: output ?? this.output,
        cellsCount: cellsCount ?? this.cellsCount,
        cellVectorLength: cellVectorLength ?? this.cellVectorLength,
        version: version ?? this.version
    );

  }*/

  @override
  IndividualBase? cross(IndividualBase target) {

    //return target.deepCopy();
    assertsTest();
    if (random.nextInt(100) > 50) {

      return target.deepCopy()..mutate();
    }

    return deepCopy()..mutate();

  }

  @override
  AiAlgorithm getAlgorithm() {
    return tree!;
  }

  @override
  int getAlgorithmVersion() {
    return version;
  }

  @override
  double getFitness() {
    return fitness;
  }

  @override
  List<double> getFitnessHistory() {
    return fitnessHistory;
  }

  @override
  void mutate() {

    /*

    Список мутаций:

    1) Добавление новой связи от одного к другому существующему узлу
    2) Добавление нового узла со связью к сещуствующему узлу
    3) Создание связи от существующего узла к новому
    4) Создание связи от существующего узла к новому
    5) Изменить вес ребра
    6) Изменить активацию узла

    */

    final allNodesId = tree!.getNodesId();
    final allNodesCount = allNodesId.length;

    final idCalculator = tree!.getIdCalculator();

    int randomValue = random.nextInt(1000);

    if (randomValue <= 250) {
      // Новая связь
      final firstNodeIndex = random.nextInt(allNodesCount);
      final secondNodeIndex = random.nextInt(allNodesCount);
      if (firstNodeIndex == secondNodeIndex) {
        return;
      }
      final res = tree!.addEdge(
          allNodesId[firstNodeIndex],
          allNodesId[secondNodeIndex],
          EdgeV1.random(idCalculator.getNextId()));
      if (res) {
        print('Успешная мутация!');
      }
      adjacencyDictKeys = adjacencyDict!.keys.toList();
      adjacencyDictValues = adjacencyDict!.values.toList();
      assertsTest();
      return;


    } else if (randomValue > 250 && randomValue <= 500) {
      // Новый узел к существующему
      final secondNodeIndex = random.nextInt(allNodesCount);
      final res = tree!.addNewPrevNode(
          allNodesId[secondNodeIndex],
          NodeV1.random(idCalculator.getNextId()),
          EdgeV1.random(idCalculator.getNextId()));
      if (res) {
        print('Успешная мутация!');
      }
      adjacencyDictKeys = adjacencyDict!.keys.toList();
      adjacencyDictValues = adjacencyDict!.values.toList();
      assertsTest();
      return;

    } else if (randomValue > 500 && randomValue <= 750) {
      // Существующий к новому
      final firstNodeIndex = random.nextInt(allNodesCount);
      final res = tree!.addNewNextNode(
          allNodesId[firstNodeIndex],
          NodeV1.random(idCalculator.getNextId()),
          EdgeV1.random(idCalculator.getNextId()));
      if (res) {
        print('Успешная мутация!');
      }
      adjacencyDictKeys = adjacencyDict!.keys.toList();
      adjacencyDictValues = adjacencyDict!.values.toList();
      assertsTest();
      return;

    } else {
      // Новый узел между
      final firstNodeIndex = random.nextInt(allNodesCount);
      final secondNodeIndex = random.nextInt(allNodesCount);
      final res = tree!.addNodeBetween(
          allNodesId[firstNodeIndex],
          allNodesId[secondNodeIndex],
          NodeV1.random(idCalculator.getNextId()),
          EdgeV1.random(idCalculator.getNextId()),
          EdgeV1.random(idCalculator.getNextId())
      );
      if (res) {
        print('Успешная мутация!');
      }
      adjacencyDictKeys = adjacencyDict!.keys.toList();
      adjacencyDictValues = adjacencyDict!.values.toList();
      assertsTest();
    }

    adjacencyDictKeys = adjacencyDict!.keys.toList();
    adjacencyDictValues = adjacencyDict!.values.toList();
    assertsTest();
  }

  @override
  void setFitness(double fitness) {
    this.fitness = fitness;
  }

  factory NeatIndivid.fromJson(Map<String, dynamic> json) =>
      _$NeatIndividFromJson(json);
  @override
  Map<String, dynamic> toJson() {
    adjacencyDictValues = adjacencyDict!.values.toList();
    adjacencyDictKeys = adjacencyDict!.keys.toList();
    assertsTest();
    return _$NeatIndividToJson(this);
  }

  @override
  IndividualBase deepCopy() {

    final newNodes = nodes!.map((e) => e.deepCopy()).toList();
    final newNodesMap = <int, NodeV1>{};
    for (var i in nodesMap!.entries) {
      newNodesMap[i.key] = i.value.deepCopy();
    }

    final newEdges = edges!.map((e) => e.deepCopy()).toList();
    final newEdgesMap = <int, EdgeV1>{};
    for (var i in edgesMap!.entries) {
      newEdgesMap[i.key] = i.value.deepCopy();
    }

    final newAdjKeys = <AdjacencyDictKey>[];
    for (var i in adjacencyDictKeys!) {
      newAdjKeys.add(i.deepCopy());
    }
    final newAdjValues = <EdgeV1>[];
    for (var i in adjacencyDictValues!) {
      // Важно учесть, что в списке хранятся ссылки на связи newEdges
      newAdjValues.add(newEdgesMap[i.getId()]!);
    }

    final newAdjList = <int, List<int>>{};
    for (var i in adjacencyList!.entries) {
      newAdjList[i.key] = i.value.map((e) => e).toList();
    }

    final newInputCompleter = <int, NodesInputCounter>{};
    for (var i in inputCompleter!.entries) {
      newInputCompleter[i.key] = i.value.deepCopy();
    }

    final newNodesStartState = <int, bool>{};
    for (var i in nodesStartState!.entries) {
      newNodesStartState[i.key] = i.value;
    }

    return NeatIndivid(

        nodes: newNodes,
        nodesMap: newNodesMap,
        edges: newEdges,
        edgesMap: newEdgesMap,

        adjacencyDictKeys: newAdjKeys,
        adjacencyDictValues: newAdjValues,
        adjacencyList: newAdjList,

        nodesStartState: newNodesStartState,
        inputCompleter: newInputCompleter,

        // Словарь смежностей передаётся пустой, т.к. в конструкторе он заполнится
        // значениями из adjacencyDictKeys и adjacencyDictValues
        adjacencyDict: {},

        initFrom: true,
        fitness: 0.0,
        fitnessHistory: [],
        needCalculate: true,
        input: input,
        output: output,
        cellsCount: cellsCount,
        cellVectorLength: cellVectorLength,
        version: version);

  }

}