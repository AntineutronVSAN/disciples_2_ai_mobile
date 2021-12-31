import 'dart:collection';

import 'package:d2_ai_v2/optim_algorythm/neat/adjacency_dict.dart';
import 'package:d2_ai_v2/optim_algorythm/neat/edge_base.dart';
import 'package:d2_ai_v2/optim_algorythm/neat/edges/edge_v1.dart';

import 'package:d2_ai_v2/optim_algorythm/neat/node_base.dart';
import 'package:d2_ai_v2/optim_algorythm/neat/nodes/node_v1.dart';

import '../game_tree_base.dart';
import '../id_calculator.dart';


import 'package:json_annotation/json_annotation.dart';

part 'tree_v1.g.dart';


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
  final Map<int, NodesInputCounter> inputCompleter;

  /// Сколько узлов фиксированы. Их нельзя удалять и у них постоянно одинаковые
  /// id. Их количество должно быть равно [input] + [output]
  int immutableNodesCount = 0;

  /// Вспомогательный хеш, который хранит в себе значение, показывающее
  /// является ли узел стартовым, т.е. в него не входят другие узлы. Используется
  /// для поиска зацикливаний
  final Map<int, bool> nodesStartState;

  /// У каждого дерева свой присваиватель ID
  final IdCalculator? idCalculator;

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
    required this.nodesStartState,
    required this.inputCompleter,
    required this.idCalculator,
  }) {

    if (initFrom) {
      assert(idCalculator != null);
      /*assert(
      nodes.isNotEmpty &&
          nodesMap.isNotEmpty &&
          edges.isNotEmpty &&
          edgesMap.isNotEmpty &&
          //adjacencyDict.isNotEmpty &&
          //adjacencyList.isNotEmpty
          );*/

      // У id калькулятора нужно сделать оффсет
      // UPD Теперь калькулятор сериализуется вместе со всеми параметрами
      //idCalculator.setStartID(edges.length + nodes.length);

      if (edges.isNotEmpty && adjacencyDict.isEmpty) {
        print('asdfasfd');
        throw Exception();
      }

    } else {
      /*assert(nodes.isEmpty &&
          nodesMap.isEmpty &&
          edges.isEmpty &&
          edgesMap.isEmpty &&
          adjacencyDict.isEmpty &&
          adjacencyList.isEmpty);*/
      _initRandom();
    }
  }

  void _initRandom() {
    // Входные узлы. id узла равен индексу элемента входного вектора
    var i = 0;
    for (; i < input; i++) {
      final newNode = NodeV1.randomWithoutActivation(idCalculator!.fromID(i));
      // id узла newNode равен индексу i вектора input
      final currentNodeID = newNode.getId();
      nodes.add(newNode);
      nodesMap[currentNodeID] = newNode;
      adjacencyList[currentNodeID] = [];
      inputCompleter[currentNodeID] = NodesInputCounter.empty();
      nodesStartState[currentNodeID] = true;
    }
    // Выходные узлы
    for (; i < input + output; i++) {
      final newNode = NodeV1.randomWithoutActivation(idCalculator!.fromID(i));
      // id узла newNode равен индексу i вектора input
      final currentNodeID = newNode.getId();
      nodes.add(newNode);
      nodesMap[currentNodeID] = newNode;
      adjacencyList[currentNodeID] = [];
      inputCompleter[currentNodeID] = NodesInputCounter.empty();
      nodesStartState[currentNodeID] = false;
    }
    assert(nodes.length == input + output);
    _test();
  }

  /// Своеобразный юнит тест топологии
  void _test() {

    // todo Убрать после отладки


    for( var i in inputCompleter.entries) {
      if (i.key < input) {
        if (i.value.getMaxInputCount() != 0) {
          print('asdfasdf');
          throw Exception();
        }
      } else {
        break;
      }
    }

    assert(edges.length == adjacencyDict.length);

  }

  @override
  List<double> forward(List<double> inp) {
    /*
      Ради эксперимента и более читабельного кода отказался от рекурсивного
      алгоритма. Возможно, в будущем для сравнения будет добавлен и рекурсивный
      алгоритм
    */
    _test();
    // Очередь обработки узлов
    Queue<int> inputQueue = Queue<int>();
    Queue<int> outputQueue = Queue<int>();
    Queue<int> otherQueue = Queue<int>();

    // Первые в очереди - входные узлы
    // Следующие все остальные
    // В конце уже выходные узлы

    // В конечном итоге, должны обработаться все узлы, а выходные узлы
    // джолжны выдать результаты. Если результаты не смогут выдать, значит
    // что-то работает не правлильно

    for (var i = 0; i < input; i++) {
      inputQueue.add(nodes[i].getId());
    }
    for (var i = input; i < input + output; i++) {
      outputQueue.add(nodes[i].getId());
    }
    for (var i = input + output; i < nodes.length; i++) {
      otherQueue.add(nodes[i].getId());
    }

    assert(otherQueue.length + inputQueue.length + outputQueue.length ==
        nodes.length);

    int stopCounter = 0;

    while (true) {
      stopCounter++;
      if (inputQueue.isEmpty) {
        break;
      }
      if (stopCounter > input + 1) {
        throw Exception();
      }
      int currentNodeID = inputQueue.removeFirst();
      final currentNode = nodesMap[currentNodeID]!;
      // Проверка, все ли имеются данные, которые приходят в узел
      // Т.к. это первые узлы, то данные должны быть
      if (!inputCompleter[currentNodeID]!.isComplete()) {
        print('asdfasdfasdf');
        throw Exception();
      }
      // Выходное значение после узла
      final value = currentNode.calculate([inp[currentNodeID]]);
      // Следующие узлы ищутся через хеш таблицу смежностей
      final nextNodesIdList = adjacencyList[currentNodeID]!;
      for (var nextNodeID in nextNodesIdList) {
        // Ищётся ребро между узлами, данные прогоняются через ребро
        // и отправляется в список inputs следующего узла.
        final currentAdjKey =
            AdjacencyDictKey(child: nextNodeID, parent: currentNodeID);

        if (adjacencyDict[currentAdjKey] == null) {
          print('asdfasdf');
          throw Exception();
        }
        final currentEdgeObject = adjacencyDict[currentAdjKey]!;

        final data = currentEdgeObject.calculate(value);
        inputCompleter[nextNodeID]!.addCompleteValue(data);
      }
    }

    stopCounter = 0;
    while (true) {
      stopCounter++;
      if (stopCounter > 10000000) {
        print('adfadf');
        throw Exception();
      }
      if (otherQueue.isEmpty) {
        break;
      }

      int currentNodeID = otherQueue.removeFirst();
      final currentNode = nodesMap[currentNodeID]!;

      // Если узел ещё не получил все данные от предыдущих узлов, узел помещяется
      // в конец очереди. Надеемся, что всё работает как нужно, и данные дойдут
      // до узла. В противном случае, сработает исключение по значению stopCounter
      final nodeCompleter = inputCompleter[currentNodeID]!;
      if (!nodeCompleter.isComplete()) {
        otherQueue.addLast(currentNodeID);
        continue;
      }

      // Все значения предыдущих узлов хранятся в nodeCompleter
      final inputVector = nodeCompleter.getValues();
      // Выходное значение после узла
      final value = currentNode.calculate(inputVector);
      // Значения очищаются сразу в целях улушчения производительности
      nodeCompleter.clear();

      // Следующие узлы ищутся через хеш таблицу смежностей
      final nextNodesIdList = adjacencyList[currentNodeID]!;
      for (var nextNodeID in nextNodesIdList) {
        // Ищётся ребро между узлами, данные прогоняются через ребро
        // и отправляется в список inputs следующего узла.
        final currentAdjKey =
        AdjacencyDictKey(child: nextNodeID, parent: currentNodeID);
        final currentEdgeObject = adjacencyDict[currentAdjKey]!;

        final data = currentEdgeObject.calculate(value);
        inputCompleter[nextNodeID]!.addCompleteValue(data);
      }
    }

    stopCounter = 0;
    List<double> resultVector = [];
    while (true) {
      stopCounter++;
      if (stopCounter > output + 1) {
        throw Exception();
      }
      if (outputQueue.isEmpty) {
        break;
      }

      int currentNodeID = outputQueue.removeFirst();
      final currentNode = nodesMap[currentNodeID]!;

      // Если узел ещё не получил все данные от предыдущих узлов, узел помещяется
      // в конец очереди. Надеемся, что всё работает как нужно, и данные дойдут
      // до узла. В противном случае, сработает исключение по значению stopCounter
      final nodeCompleter = inputCompleter[currentNodeID]!;
      if (!nodeCompleter.isComplete()) {
        throw Exception("Выходные узлы должны быть обязательно завершены, "
            "неверная логика");
      }

      // Все значения предыдущих узлов хранятся в nodeCompleter
      final inputVector = nodeCompleter.getValues();
      // Выходное значение после узла
      final value = currentNode.calculate(inputVector);
      // Значения очищаются сразу в целях улушчения производительности
      nodeCompleter.clear();

      resultVector.add(value);

    }

    assert(resultVector.length == output, "${resultVector.length} != $output");
    _test();
    return resultVector;
  }

  /// Проверить дерево на предмет зацикливаний
  bool _checkTreeCycles({TreeV1? snapshot}) {
    _CycleFindBypassContext context = _CycleFindBypassContext();
    List<int> allStartNodes = [];

    final entries = snapshot == null
        ? nodesStartState.entries
        : snapshot.nodesStartState.entries;

    for(var i in entries) {
      if (i.value) {
        allStartNodes.add(i.key);
      }
    }
    for(var id in allStartNodes) {
      context.refresh();
      //print('--------------------- ID = $id');
      final res = _checkTreeCyclesBypass(id, context, snapshot: snapshot);
      if (!res) {
        print('Дерево зациклено!');
        return false;
      }
    }
    _test();
    return true;
  }

  bool _checkTreeCyclesBypass(int nodeId, _CycleFindBypassContext context, {TreeV1? snapshot}) {
    context.visitedNodes[nodeId] = true;
    context.addRec();

    final adjList = snapshot == null ? adjacencyList : snapshot.adjacencyList;

    for(var nextId in adjList[nodeId]!) {
      //print('next - $nextId');
      if (context.visitedNodes[nextId] != null) {
        return false;
      }
      final res = _checkTreeCyclesBypass(nextId, context, snapshot: snapshot);
      if (!res) {
        return false;
      }
    }

    return true;
  }

  @override
  bool addEdge(int n1, int n2, TreeEdgeBase edge) {
    /* n1 -> edge -> n2 */
    //return false;
    // Запрещено добавлять связи между входными узлами
    if (n1 < input && n2 < input) {
      //print('Запрещено добавлять связи между входными узлами');
      return false;
    }
    // Запрещено добавлять связь от выходного узла
    if (n1 >= input && n1 < output+input) {
      //throw Exception("Запрещено добавлять связь от выходного узла");
      return false;
    }
    if (n2 < input) {
      //throw Exception("Запрещено добавлять связь к входному узлу");
      return false;
    }

    if (n1 == n2) {
      throw Exception("Запреещно добавлять связь между одним и тем же узлом");
    }

    final newKey = AdjacencyDictKey(child: n2, parent: n1);
    final hasKey = adjacencyDict.containsKey(newKey);

    if (hasKey) {
      return false;
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
    inputCompleter[n2]!.addMaxCount(1);

    final lastState = nodesStartState[n2]!;
    nodesStartState[n2] = false;

    // При добавлении связи между существующими узлами, дерево может
    // зациклиться. Необходимо проверить
    final treeCorrect = _checkTreeCycles();
    if (!treeCorrect) {
      // Сброс
      adjacencyDict.remove(newKey);
      edgesMap.remove(edge.getId());
      edges.removeWhere((element) => element.getId() == edge.getId());
      adjacencyList[n1]!.removeWhere((element) => element == n2);
      inputCompleter[n2]!.addMaxCount(-1);
      nodesStartState[n2] = lastState;
      _test();
      return false;
    }
    _test();
    return true;
  }

  @override
  bool addNewNextNode(int current, TreeNodeBase node, TreeEdgeBase edge) {
    /* current -> edge -> node */
    if (current >= input && current < output+input) {
      //throw Exception("Запрещено добавить связь от выходного узла");
      return false;
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
      //throw Exception();
      return false;
    }
    nodes.add(node);
    nodesMap[newNodeID] = node;
    edges.add(edge);
    edgesMap[newEdgeID] = edge;

    adjacencyDict[newKey] = edge;
    adjacencyList[current]!.add(newNodeID);
    adjacencyList[newNodeID] = [];

    assert(inputCompleter[newNodeID] == null);
    inputCompleter[newNodeID] = NodesInputCounter.empty();
    inputCompleter[newNodeID]!.addMaxCount(1);

    nodesStartState[newNodeID] = false;
    _test();
    return true;
  }

  @override
  bool addNewPrevNode(int target, TreeNodeBase node, TreeEdgeBase edge) {
    /* node -> edge -> target */
    if (target < input) {
      //throw Exception("Запрещено добавлять связь к входному узлу");
      return false;
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
      //throw Exception();
      return false;
    }

    nodes.add(node);
    nodesMap[newNodeID] = node;
    assert(inputCompleter[newNodeID] == null);
    inputCompleter[newNodeID] = NodesInputCounter.empty();

    edges.add(edge);
    edgesMap[newEdgeID] = edge;

    adjacencyDict[newKey] = edge;
    assert(adjacencyList[newNodeID] == null);
    adjacencyList[newNodeID] = [];
    adjacencyList[newNodeID]!.add(target);

    assert(nodesStartState[newNodeID] == null);
    nodesStartState[newNodeID] = true;
    nodesStartState[target] = false;

    inputCompleter[target]!.addMaxCount(1);
    _test();
    return true;
  }

  @override
  bool addNodeBetween(
      int n1, int n2, TreeNodeBase n, TreeEdgeBase e1, TreeEdgeBase e2) {
    // n1 -> e1 -> n -> e2 -> n2
    if (n1 < input && n2 < input) {
      //throw Exception("Запрещено добавлять связи между входными узлами");
      return false;
    }
    if (n2 < input) {
      //throw Exception("Запрещено добавлять связи к входному узлу");
      return false;
    }
    if (n1 >= input && n2 <= output) {
      //throw Exception("Запрещено добавлять связь от выходного узла");
      return false;
    }
    if (nodesStartState[n2]!) {
      // Узел может быть и не стартовым
      //throw Exception();
    }
    if (n1 == n2) {
      //throw Exception("Запрещено добавлять узел между одним и тем же узлом");
      return false;
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

    final currentKey = AdjacencyDictKey(child: n2, parent: n1);

    // Связи между узлами может и не быть
    /*if (!adjacencyDict.containsKey(currentKey)) {
      throw Exception();
    }*/
    if (adjacencyDict.containsKey(firstKey) ||
        adjacencyDict.containsKey(secondKey)) {
      throw Exception();
    }

    // Делается snapshot текущего состояния. На нём делаются изменения и
    // смотрятся зацикливания в дереве. Это очень тяжёлая операция, но
    // ничего лучше пока я не придумал. Проблема в том, что после изменений
    // (которых очень много) дерево может зациклиться и необходимо вернуться
    // в исходное состояние. Всё усугубляется тем, что создающий дерево
    // объект хранит в себе ссылки на поля дерева, и изменять их нельзя.
    final snapshot = deepCopy() as TreeV1;
    // Только после успешного добавления в снапшоте, добавялется в текущем дереве
    if (!_checkTreeCyclesAfterAddEdge(
        snapshot: snapshot,
        n1: n1,
        n2: n2,
        n: n,
        e1: e1,
        e2: e2)) {
      return false;
    }

    nodes.add(n);
    nodesMap[newNodeID] = n;
    assert(inputCompleter[newNodeID] == null);
    inputCompleter[newNodeID] = NodesInputCounter.empty();

    edges.add(e1);
    edges.add(e2);
    edgesMap[firstEdgeID] = e1;
    edgesMap[secondEdgeID] = e2;

    adjacencyDict[firstKey] = e1;
    adjacencyDict[secondKey] = e2;
    // n1 -> n -> n2
    assert(adjacencyList[newNodeID] == null);
    adjacencyList[newNodeID] = [];
    adjacencyList[newNodeID]!.add(n2);

    adjacencyList[n1]!.add(newNodeID);
    adjacencyList[n1]!.removeWhere((element) => element == n2);

    inputCompleter[newNodeID]!.addMaxCount(1);
    assert(nodesStartState[newNodeID] == null);
    nodesStartState[newNodeID] = false;
    nodesStartState[n2] = false;

    assert(edges.length == adjacencyDict.length);
    // Необходимо удалить существующие связи, если они есть
    if (adjacencyDict[currentKey] != null) {
      final deletedEdgeID = adjacencyDict[currentKey]!.getId();
      adjacencyDict.remove(currentKey);
      final deleteEdgeRes = edgesMap.remove(deletedEdgeID);
      assert(deleteEdgeRes != null);
      edges.removeWhere((element) => element.getId() == deletedEdgeID);
    } else {
      // Если связи между n1->n2 не сущестововало, к комплитеру n2 добавялется
      // значение
      assert(inputCompleter[n2] != null);
      inputCompleter[n2]!.addMaxCount(1);
    }

    if (!_checkTreeCycles()) {
      throw Exception("Зацикливания должны быть проверены в снапшоте. Неверная логика");
      _test();
      return false;
    }

    _test();
    return true;
  }

  bool _checkTreeCyclesAfterAddEdge(
      {required TreeV1 snapshot,
        required int n1,
        required int n2,
        required TreeNodeBase n,
        required TreeEdgeBase e1,
        required TreeEdgeBase e2}) {

    final newNodeID = n.getId();
    final firstEdgeID = e1.getId();
    final secondEdgeID = e2.getId();

    final firstKey = AdjacencyDictKey(child: newNodeID, parent: n1);
    final secondKey = AdjacencyDictKey(child: n2, parent: newNodeID);

    final currentKey = AdjacencyDictKey(child: n2, parent: n1);

    snapshot.nodes.add(n);
    snapshot.nodesMap[newNodeID] = n;
    assert(snapshot.inputCompleter[newNodeID] == null);
    snapshot.inputCompleter[newNodeID] = NodesInputCounter.empty();

    snapshot.edges.add(e1);
    snapshot.edges.add(e2);
    snapshot.edgesMap[firstEdgeID] = e1;
    snapshot.edgesMap[secondEdgeID] = e2;

    snapshot.adjacencyDict[firstKey] = e1;
    snapshot.adjacencyDict[secondKey] = e2;
    // n1 -> n -> n2
    assert(snapshot.adjacencyList[newNodeID] == null);
    snapshot.adjacencyList[newNodeID] = [];
    snapshot.adjacencyList[newNodeID]!.add(n2);

    snapshot.adjacencyList[n1]!.add(newNodeID);
    snapshot.adjacencyList[n1]!.removeWhere((element) => element == n2);

    snapshot.inputCompleter[newNodeID]!.addMaxCount(1);
    assert(snapshot.nodesStartState[newNodeID] == null);
    snapshot.nodesStartState[newNodeID] = false;
    snapshot.nodesStartState[n2] = false;

    assert(snapshot.edges.length == snapshot.adjacencyDict.length);
    // Необходимо удалить существующие связи, если они есть
    if (snapshot.adjacencyDict[currentKey] != null) {
      final deletedEdgeID = snapshot.adjacencyDict[currentKey]!.getId();
      snapshot.adjacencyDict.remove(currentKey);
      final deleteEdgeRes = snapshot.edgesMap.remove(deletedEdgeID);
      assert(deleteEdgeRes != null);
      snapshot.edges.removeWhere((element) => element.getId() == deletedEdgeID);
    } else {
      // Если связи между n1->n2 не сущестововало, к комплитеру n2 добавялется
      // значение
      assert(snapshot.inputCompleter[n2] != null);
      snapshot.inputCompleter[n2]!.addMaxCount(1);
    }
    return _checkTreeCycles(snapshot: snapshot);
  }


  @override
  String toString() {
    /*print('ALL NODES:');
    for (var i in nodes) {
      print('Node id = ${i.getId()}');
    }
    print('ALL EDGES:');
    for (var i in edges) {
      print('Edge id = ${i.getId()}');
    }*/
    /*print('ADJACENCY DICT:');
    for (var i in adjacencyDict.entries) {
      print('key - ${i.key} edge: ${i.value}');
    }
    print('ADJACENCY LIST:');
    for (var i in adjacencyList.entries) {
      print('node - ${i.key} next nodes ${i.value}');
    }
    print('COMPLETER VALUES:');
    for (var i in inputCompleter.entries) {
      print('Node id - ${i.key}. Value - ${i.value}');
    }
    print('NODE START STATE:');
    for(var i in nodesStartState.entries) {
      print('Node - ${i.key}, is start - ${i.value}');
    }*/
    return super.toString();
  }

  @override
  IdCalculator getIdCalculator() {
    return idCalculator!;
  }

  @override
  List<int> getNodesId() {
    return nodes.map((e) => e.getId()).toList();
  }

  @override
  GameTreeBase deepCopy() {

    final newNodes = nodes.map((e) => e.deepCopy()).toList();
    final newNodesMap = <int, TreeNodeBase>{};
    for (var i in nodesMap.entries) {
      newNodesMap[i.key] = i.value.deepCopy();
    }

    final newEdges = edges.map((e) => e.deepCopy()).toList();
    final newEdgesMap = <int, TreeEdgeBase>{};
    for (var i in edgesMap.entries) {
      newEdgesMap[i.key] = i.value.deepCopy();
    }

    final newAdjList = <int, List<int>>{};
    for (var i in adjacencyList.entries) {
      newAdjList[i.key] = i.value.map((e) => e).toList();
    }

    final newAdjDict = <AdjacencyDictKey, TreeEdgeBase>{};
    for (var i in adjacencyDict.entries) {
      newAdjDict[i.key.deepCopy()] = i.value.deepCopy();
    }

    final newInputCompleter = <int, NodesInputCounter>{};
    for (var i in inputCompleter.entries) {
      newInputCompleter[i.key] = i.value.deepCopy();
    }

    final newNodesStartState = <int, bool>{};
    for (var i in nodesStartState.entries) {
      newNodesStartState[i.key] = i.value;
    }

    return TreeV1(
        input: input,
        output: output,
        nodes: newNodes,
        nodesMap: newNodesMap,
        edges: newEdges,
        edgesMap: newEdgesMap,
        adjacencyDict: newAdjDict,
        initFrom: true,
        adjacencyList: newAdjList,
        nodesStartState: newNodesStartState,
        inputCompleter: newInputCompleter,
        idCalculator: idCalculator!.deepCopy(),
    );

  }
}

/// Вспомогательный класс, который хранит сколько всего есть входов в узел
/// и сколько на данный момент входов завершено

// todo Тесты на коллизии ключей
@JsonSerializable()
class NodesInputCounter {
  int maxInputsCount = 0;
  final List<double> currentInputs;

  NodesInputCounter({required this.currentInputs, required this.maxInputsCount});

  factory NodesInputCounter.fromJson(Map<String, dynamic> json) =>
      _$NodesInputCounterFromJson(json);
  Map<String, dynamic> toJson() => _$NodesInputCounterToJson(this);

  factory NodesInputCounter.empty() {
    return NodesInputCounter(
        currentInputs: [],
        maxInputsCount: 0);
  }

  int getMaxInputCount() {
    return maxInputsCount;
  }

  bool isComplete() {
    return currentInputs.length == maxInputsCount;
  }

  void addCompleteValue(double val) {
    currentInputs.add(val);
    if (currentInputs.length > maxInputsCount) {
      print('asdfadfafd');

    }
    assert(
        currentInputs.length <= maxInputsCount,
        'Неверная логика, входов в'
        ' узел больше, чем максимальное число входов. ${currentInputs.length} > $maxInputsCount');
  }

  List<double> getValues() {
    return currentInputs;
  }

  void clear() {
    currentInputs.clear();
  }

  void addMaxCount(int val) {
    if (val != 1 && val != -1) {
      throw Exception();
    }
    assert(currentInputs.isEmpty);
    if ((maxInputsCount + val) < 0) {
      maxInputsCount = 0;
    }
    maxInputsCount += val;
  }

  @override
  String toString() {
    return 'Max inputs $maxInputsCount. Current inputs - $currentInputs';
  }

  NodesInputCounter deepCopy() {
    return NodesInputCounter(currentInputs: currentInputs, maxInputsCount: maxInputsCount);
  }
}

/// Вспомогательный класс-контекст для обхода дерева при поиске зацикливаний
class _CycleFindBypassContext {
  Map<int, bool> visitedNodes = {};
  int recCounter = 0;
  void refresh() {
    recCounter = 0;
    visitedNodes.clear();
  }
  void addRec() {
    if (recCounter > 10000) {
      throw Exception();
    }
    recCounter++;
  }
}