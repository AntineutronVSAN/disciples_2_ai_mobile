import 'dart:math';

import 'package:d2_ai_v2/optim_algorythm/neat/edges/edge_v1.dart';
import 'package:d2_ai_v2/optim_algorythm/neat/id_calculator.dart';
import 'package:d2_ai_v2/optim_algorythm/neat/nodes/node_v1.dart';
import 'package:d2_ai_v2/optim_algorythm/neat/trees/tree_v1.dart';
import 'package:d2_ai_v2/utils/activations_mixin.dart';
import 'package:d2_ai_v2/utils/random_utils.dart';
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

  IdCalculator? idCalculator;

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
    this.idCalculator,
  }) {
    if (initFrom) {
      assert(nodes != null &&
          nodesMap != null &&
          edges != null &&
          edgesMap != null &&
          adjacencyDictKeys != null &&
          adjacencyDictValues != null &&
          adjacencyList != null &&
          inputCompleter != null &&
          nodesStartState != null &&
          idCalculator != null);
      //adjacencyDict = Map.fromIterables(adjacencyDictKeys!, adjacencyDictValues!);
      if (adjacencyDict != null) {
        adjacencyDict!.clear();
        assert(adjacencyDictKeys!.length == adjacencyDictValues!.length);
        for (var i = 0; i < adjacencyDictKeys!.length; i++) {
          adjacencyDict![adjacencyDictKeys![i]] = adjacencyDictValues![i];
        }
      } else {
        adjacencyDict =
            Map.fromIterables(adjacencyDictKeys!, adjacencyDictValues!);
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
        inputCompleter: inputCompleter!,
        idCalculator: idCalculator!,
      );
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
      idCalculator = IdCalculator();
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
        inputCompleter: inputCompleter!,
        idCalculator: idCalculator,
      );
    }

    assertsTest();
  }

  void assertsTest() {
    assert(edges!.length == adjacencyDict!.length);
    assert(edges!.length == adjacencyDictKeys!.length);
    assert(edges!.length == adjacencyDictValues!.length);
  }

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

  bool _addEdge(List<int> allNodesId, IdCalculator calculator) {
    final allNodesCount = allNodesId.length;

    //final firstNodeIndex = random.nextInt(allNodesCount);
    final firstNodeIndex = randomRanges([
      PairValues<int>(first: 0, end: input),
      PairValues<int>(first: input + output, end: allNodesCount)
    ], random);
    final secondNodeIndex = randomRanges(
        [PairValues<int>(first: input, end: allNodesCount)], random);

    if (firstNodeIndex == secondNodeIndex) {
      return false;
    }
    final res = tree!.addEdge(allNodesId[firstNodeIndex],
        allNodesId[secondNodeIndex], EdgeV1.random(calculator.getNextId(), random));
    return res;
  }

  bool _addNextNode(List<int> allNodesId, IdCalculator calculator) {
    final allNodesCount = allNodesId.length;
    final firstNodeIndex = randomRanges([
      PairValues<int>(first: 0, end: input),
      PairValues<int>(first: input + output, end: allNodesCount),
    ], random);

    final res = tree!.addNewNextNode(
        allNodesId[firstNodeIndex],
        NodeV1.random(calculator.getNextId(), random),
        EdgeV1.random(calculator.getNextId(), random));
    return res;
  }

  bool _addPrevNode(List<int> allNodesId, IdCalculator calculator) {
    final allNodesCount = allNodesId.length;

    final secondNodeIndex = randomRanges(
        [PairValues<int>(first: input, end: allNodesCount)], random);

    final res = tree!.addNewPrevNode(
        allNodesId[secondNodeIndex],
        NodeV1.random(calculator.getNextId(), random),
        EdgeV1.random(calculator.getNextId(), random));
    return res;
  }

  bool _addNodeBetween(List<int> allNodesId, IdCalculator calculator) {
    final allNodesCount = allNodesId.length;

    final firstNodeIndex = randomRanges([
      PairValues<int>(first: 0, end: input),
      PairValues<int>(first: input + output, end: allNodesCount),
    ], random);

    final secondNodeIndex = randomRanges(
        [PairValues<int>(first: input, end: allNodesCount)], random);

    final res = tree!.addNodeBetween(
        allNodesId[firstNodeIndex],
        allNodesId[secondNodeIndex],
        NodeV1.random(calculator.getNextId(), random),
        EdgeV1.random(calculator.getNextId(), random),
        EdgeV1.random(calculator.getNextId(), random));
    return res;
  }

  bool _changeRandomEdge() {
    final edgesId = tree!.getEdgesId();
    if (edgesId.isEmpty) {
      return false;
    }
    return tree!.changeEdge(getRandomElement(edgesId, random));
  }

  bool _changeRandomNode() {
    final nodesId =
        tree!.getNodesId().where((e) => e >= input + output).toList();
    if (nodesId.isEmpty) {
      return false;
    }
    return tree!.changeNode(getRandomElement(nodesId, random));
  }

  @override
  bool mutate() {
    /*

    Список мутаций:

    1) Добавление новой связи от одного к другому существующему узлу
    2) Добавление нового узла со связью к сещуствующему узлу
    3) Создание связи от существующего узла к новому
    4) Создание связи от существующего узла к новому
    5) Изменить узел
    6) Изменить ребро

    */

    final allNodesId = tree!.getNodesId();
    final idCalculator = tree!.getIdCalculator();

    bool res = false;

    callRandomFunc([
      () => res = _addEdge(allNodesId, idCalculator),
      () => res = _addNextNode(allNodesId, idCalculator),
      () => res = _addPrevNode(allNodesId, idCalculator),
      () => res = _addNodeBetween(allNodesId, idCalculator),
      () => res = _changeRandomEdge(),
      () => res = _changeRandomNode(),
    ], random);

    adjacencyDictKeys = adjacencyDict!.keys.toList();
    adjacencyDictValues = adjacencyDict!.values.toList();
    assertsTest();
    return res;
  }

  @override
  void setFitness(double fitness) {
    this.fitness = fitness;
  }

  factory NeatIndivid.fromJson(Map<String, dynamic> json) =>
      _$NeatIndividFromJson(json);

  @override
  Map<String, dynamic> toJson() {
    // Обновляются ключи и значения adjacencyDict, так как
    // они не отправляются в дерево, но связаны с adjacencyDict
    adjacencyDictValues = adjacencyDict!.values.toList();
    adjacencyDictKeys = adjacencyDict!.keys.toList();
    // Когда индивид сериализуется, он должен быть инициализирован с данных при
    // десериализации
    initFrom = true;
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

    final newIdCalculator = idCalculator!.deepCopy();

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
        idCalculator: newIdCalculator,

        // Словарь смежностей передаётся пустой, т.к. в конструкторе он заполнится
        // значениями из adjacencyDictKeys и adjacencyDictValues
        // Это всё сделано по той причине, что json сериализация не даёт
        // сериализовать ключи-классы
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
