import 'dart:collection';

import 'package:d2_ai_v2/optim_algorythm/neat/adjacency_dict.dart';
import 'package:d2_ai_v2/optim_algorythm/neat/edge_base.dart';

import 'package:d2_ai_v2/optim_algorythm/neat/node_base.dart';
import 'package:d2_ai_v2/optim_algorythm/neat/nodes/node_v1.dart';

import '../game_tree_base.dart';
import '../id_calculator.dart';

class TreeV1 implements GameTreeBase {
  final List<TreeNodeBase> nodes;
  final Map<int, TreeNodeBase> nodesMap;

  final List<TreeEdgeBase> edges;
  final Map<int, TreeEdgeBase> edgesMap;

  /// Размер входного вектора
  final int input;
  /// Размер выходного вектора
  final int output;

  /// Словарь смежностей с объектом ребра
  final Map<AdjacencyDictKey, TreeEdgeBase> adjacencyDict;
  /// Словарь смежностей со списком следующих узлов
  final Map<int, List<int>> adjacencyList;

  /// Флаг укажет, нужно ли инициализировать дерево из данных
  final bool initFrom;

  /// Вспомогательный словарь, который хранит информацию о узле:
  /// сколько всего входов в узел, и сколько входов завершено
  final Map<int, _NodesInputCounter> _inputCompleter = {};

  /// Сколько узлов фиксированы. Их нельзя удалять и у них постоянно одинаковые
  /// id. Их количество должно быть равно [input] + [output]
  int immutableNodesCount = 0;

  TreeV1({
    required this.input,
    required this.output,
    required this.nodes,
    required this.nodesMap,
    required this.edges,
    required this.edgesMap,
    required this.adjacencyDict,
    required this.initFrom,
    required this.adjacencyList,
  }) {
    if (initFrom) {
      assert(nodes.isNotEmpty &&
          nodesMap.isNotEmpty &&
          edges.isNotEmpty &&
          edgesMap.isNotEmpty &&
          adjacencyDict.isNotEmpty &&
      adjacencyList.isNotEmpty);
    } else {
      assert(nodes.isEmpty &&
          nodesMap.isEmpty &&
          edges.isEmpty &&
          edgesMap.isEmpty &&
          adjacencyDict.isEmpty &&
      adjacencyList.isEmpty);
      _initRandom();
    }
  }

  void _initRandom() {
    // Входные узлы. id узла равен индексу элемента входного вектора
    var i = 0;
    for (;i < input; i++) {
      final newNode = NodeV1.randomWithoutActivation(IdCalculator.fromID(i));
      // id узла newNode равен индексу i вектора input
      final currentNodeID = newNode.getId();
      nodes.add(newNode);
      nodesMap[currentNodeID] = newNode;
      adjacencyList[currentNodeID] = [];
      _inputCompleter[currentNodeID] = _NodesInputCounter();
    }
    // Выходные узлы
    for (;i < input+output; i++) {
      final newNode = NodeV1.randomWithoutActivation(IdCalculator.fromID(i));
      // id узла newNode равен индексу i вектора input
      final currentNodeID = newNode.getId();
      nodes.add(newNode);
      nodesMap[currentNodeID] = newNode;
      adjacencyList[currentNodeID] = [];
      _inputCompleter[currentNodeID] = _NodesInputCounter();
    }
    assert(nodes.length == input + output);
  }

  @override
  List<double> forward(List<double> inp) {

    // Очередь обработки узлов
    Queue<int> nodesIdQueue = Queue<int>();

    // Первые в очереди - входные узлы
    // Следующие все остальные
    // В конце уже выходные узлы
    for(var i=0; i<input; i++) {
      nodesIdQueue.add(nodes[i].getId());

      while(true) {

        int currentNodeID = nodesIdQueue.removeFirst();
        final currentNode = nodesMap[currentNodeID]!;

        // Проверка, все ли имеются данные, которые приходят в узел
        // Т.к. это первые узлы, то данные должны быть
        if (!_inputCompleter[currentNodeID]!.isComplete()) {
          throw Exception();
        }

        final value = currentNode.calculate([inp[currentNodeID]]);

        // Следующие узлы ищутся через хеш таблицу смежностей


      }

    }

    return [];
  }


  @override
  bool addEdge(int n1, int n2, TreeEdgeBase edge) {

    // Запрещено добавлять связи между входными узлами
    if (n1 <= input && n2 <= input) {
      throw Exception("Запрещено добавлять связи между входными узлами");
    }
    // Запрещено добавлять связь от выходного узла
    if (n1 > input && n1 <= output) {
      throw Exception("Запрещено добавлять связь от выходного узла");
    }

    if (n1 == n2) {
      throw Exception("Запреещно добавлять связь между одним и тем же узлом");
    }

    final newKey = AdjacencyDictKey(child: n2, parent: n1);
    final hasKey = adjacencyDict.containsKey(newKey);
    if (hasKey) {
      throw Exception();
    }
    final hasEdge = edgesMap.containsKey(edge.getId());
    if (hasEdge) {
      throw Exception();
    }
    final hasN1 = nodesMap.containsKey(n1);
    final hasN2 = nodesMap.containsKey(n2);
    if (!hasN1 || !hasN2) {
      throw Exception();
    }
    adjacencyDict[newKey] = edge;
    edges.add(edge);
    edgesMap[edge.getId()] = edge;

    adjacencyList[n1]!.add(n2);

    // Обновляется число входных данных для узла n2
    _inputCompleter[n2]!.addMaxCount(1);

    return true;
  }

  @override
  bool addNewNextNode(int current, TreeNodeBase node, TreeEdgeBase edge) {
    if (current > input && current <= output) {
      throw Exception("Запрещено добавить связь от выходного узла");
    }

    final newNodeID = node.getId();
    final newEdgeID = edge.getId();

    final hasCurrentNode = nodesMap.containsKey(current);
    final hasTargetNode = nodesMap.containsKey(newNodeID);
    final hasEdge = edgesMap.containsKey(newEdgeID);
    final newKey = AdjacencyDictKey(child: newNodeID, parent: current);

    if (!hasCurrentNode) {
      throw Exception();
    }
    if (hasTargetNode) {
      throw Exception();
    }
    if (hasEdge) {
      throw Exception();
    }
    if (adjacencyDict.containsKey(newKey)) {
      throw Exception();
    }
    nodes.add(node);
    nodesMap[newNodeID] = node;
    edges.add(edge);
    edgesMap[newEdgeID] = edge;

    adjacencyDict[newKey] = edge;
    adjacencyList[current]!.add(newNodeID);
    adjacencyList[newNodeID] = [];

    _inputCompleter[newNodeID] = _NodesInputCounter();
    _inputCompleter[newNodeID]!.addMaxCount(1);
    return true;
  }

  @override
  bool addNewPrevNode(int target, TreeNodeBase node, TreeEdgeBase edge) {
    if (target <= input) {
      throw Exception("Запрещено добавлять связь к входному узлу");
    }
    final newNodeID = node.getId();
    final newEdgeID = edge.getId();

    final hasCurrentNode = nodesMap.containsKey(target);
    final hasTargetNode = nodesMap.containsKey(newNodeID);
    final hasEdge = edgesMap.containsKey(newEdgeID);
    final newKey = AdjacencyDictKey(child: target, parent: newNodeID);

    if (!hasCurrentNode) {
      throw Exception();
    }
    if (hasTargetNode) {
      throw Exception();
    }
    if (hasEdge) {
      throw Exception();
    }
    if (adjacencyDict.containsKey(newKey)) {
      throw Exception();
    }

    nodes.add(node);
    nodesMap[newNodeID] = node;
    _inputCompleter[newNodeID] = _NodesInputCounter();

    edges.add(edge);
    edgesMap[newEdgeID] = edge;

    adjacencyDict[newKey] = edge;
    adjacencyList[target]!.add(newNodeID);
    adjacencyList[newNodeID] = [];

    _inputCompleter[target]!.addMaxCount(1);
    return true;
  }

  @override
  bool addNodeBetween(int n1, int n2, TreeNodeBase n,
      TreeEdgeBase e1, TreeEdgeBase e2) {
    // n1 -> n -> n2
    if (n1 <= input && n2 <= input) {
      throw Exception("Запрещено добавлять связи между входными узлами");
    }

    final newNodeID = n.getId();
    final firstEdgeID = e1.getId();
    final secondEdgeID = e2.getId();

    final hasFirstNode = nodesMap.containsKey(n1);
    final hasSecondNode = nodesMap.containsKey(n2);
    final hasNewNode = nodesMap.containsKey(newNodeID);

    final hasFirstEdge = edgesMap.containsKey(firstEdgeID);
    final hasSecondEdge = edgesMap.containsKey(secondEdgeID);

    if (!hasFirstNode || !hasSecondNode) {
      throw Exception();
    }
    if (hasNewNode) {
      throw Exception();
    }
    if (hasFirstEdge || hasSecondEdge) {
      throw Exception();
    }

    final firstKey = AdjacencyDictKey(child: newNodeID, parent: n1);
    final secondKey = AdjacencyDictKey(child: n2, parent: newNodeID);

    final currentKey = AdjacencyDictKey(child: n1, parent: n2);

    if (!adjacencyDict.containsKey(currentKey)) {
      throw Exception();
    }
    if (adjacencyDict.containsKey(firstKey) || adjacencyDict.containsKey(secondKey)) {
      throw Exception();
    }

    nodes.add(n);
    nodesMap[newNodeID] = n;
    _inputCompleter[newNodeID] = _NodesInputCounter();

    edges.add(e1);
    edges.add(e2);
    edgesMap[firstEdgeID] = e1;
    edgesMap[secondEdgeID] = e2;

    adjacencyDict[firstKey] = e1;
    adjacencyDict[secondKey] = e2;
    // n1 -> n -> n2
    adjacencyList[newNodeID] = [];
    adjacencyList[newNodeID]!.add(n2);
    adjacencyList[n1]!.add(newNodeID);
    adjacencyList[n1]!.removeWhere((element) => element == n2);

    _inputCompleter[newNodeID]!.addMaxCount(1);

    // Необходимо удалить существующие связи
    final deletedEdgeID = adjacencyDict[currentKey]!.getId();
    adjacencyDict.remove(currentKey);
    edgesMap.remove(deletedEdgeID);
    edges.removeWhere((element) => element.getId() == deletedEdgeID);

    return true;
  }

  @override
  String toString() {

    print('ALL NODES:');
    for(var i in nodes) {
      print('Node id = ${i.getId()}');
    }
    print('ALL EDGES:');
    for(var i in edges) {
      print('Edge id = ${i.getId()}');
    }
    print('ADJACENCY DICT:');
    for(var i in adjacencyDict.entries) {
      print('key - ${i.key} edge: ${i.value}');
    }
    print('ADJACENCY LIST:');
    for(var i in adjacencyList.entries) {
      print('node - ${i.key} next nodes ${i.value}');
    }
    print('COMPLETER VALUES:');
    for(var i in _inputCompleter.entries) {
      print('Node id - ${i.key}. Value - ${i.value}');
    }

    return super.toString();
  }
}


/// Вспомогательный класс, который хранит сколько всего есть входов в узел
/// и сколько на данный момент входов завершено
class _NodesInputCounter {
  int _maxInputsCount = 0;
  final List<double> _currentInputs = [];

  bool isComplete() {
    return _currentInputs.length == _maxInputsCount;
  }

  void addCompleteValue(double val) {
    _currentInputs.add(val);
    assert(_currentInputs.length > _maxInputsCount, 'Неверная логика, входов в'
        ' узел больше, чем максимальное число входов');
  }

  void clear() {
    _currentInputs.clear();
  }

  void addMaxCount(int val) {
    _maxInputsCount += val;
  }

  @override
  String toString() {
    return 'Max inputs $_maxInputsCount. Current inputs - $_currentInputs';
  }
}
