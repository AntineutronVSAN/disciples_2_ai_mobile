import 'dart:collection';
import 'dart:math';

import 'package:d2_ai_v2/optim_algorythm/neat/adjacency_dict.dart';
import 'package:d2_ai_v2/optim_algorythm/neat/edge_base.dart';
import 'package:d2_ai_v2/optim_algorythm/neat/edges/edge_v1.dart';

import 'package:d2_ai_v2/optim_algorythm/neat/node_base.dart';
import 'package:d2_ai_v2/optim_algorythm/neat/nodes/node_v1.dart';

import '../game_tree_base.dart';
import '../id_calculator.dart';

import 'package:json_annotation/json_annotation.dart';

part 'tree_v1.g.dart';

/*

  TODO:
   * Автоматическая оптимизация дерева.
     * Например связи n1->n2->n3->4 можно ужать до n1->n4
     * Очистка всех узлов без связей
   * Удалить узел
   * Удалить связь
   * Удалить ветку
   * Удалить подветку от узла
   * Добавить ветвь
   * Добавить подветвь от узла


*/

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
      _initRandom(Random());
    }
  }

  void _initRandom(Random random) {
    // Входные узлы. id узла равен индексу элемента входного вектора
    var i = 0;
    for (; i < input; i++) {
      final newNode =
          NodeV1.randomWithoutActivation(idCalculator!.fromID(i), random);
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
      final newNode = NodeV1.random(idCalculator!.fromID(i), random);
      // id узла newNode равен индексу i вектора input
      final currentNodeID = newNode.getId();
      nodes.add(newNode);
      nodesMap[currentNodeID] = newNode;
      adjacencyList[currentNodeID] = [];
      inputCompleter[currentNodeID] = NodesInputCounter.empty();
      nodesStartState[currentNodeID] = false;
    }
    assert(nodes.length == input + output);
    _test(tree: this);
  }

  /// Своеобразный юнит тест топологии
  static void _test({bool needForward = true, required TreeV1 tree}) {
    // todo Убрать после отладки
    for (var i in tree.inputCompleter.entries) {
      if (i.key < tree.input) {
        if (i.value.getMaxInputCount() != 0) {
          throw Exception();
        }
      } else {
        break;
      }
    }

    // Случается ошибка, когда узел ссылается на другой узел, но
    // в словаре смежностей такого ключа нет. Следующий блок
    // кода предназначен для выявления такого случая
    for (var i in tree.adjacencyList.entries) {
      final parentNodeId = i.key;
      for (var childNodeId in i.value) {
        final currentAdjKey =
            AdjacencyDictKey(child: childNodeId, parent: parentNodeId);
        final keyExists = tree.adjacencyDict.containsKey(currentAdjKey);
        if (!keyExists) {
          throw Exception('Узел $parentNodeId ссылается на $childNodeId в '
              'списке ${i.value}, но словарь смежностей '
              'не содержит ключ $currentAdjKey');
        }
      }
    }

    final copyCompleterValuesFromAdjList = <int, int>{};
    final copyCompleterValuesFromAdjDict = <int, int>{};
    // Тест значений комплитера
    for (var i in tree.adjacencyList.entries) {
      for (var j in i.value) {
        final hasKey = copyCompleterValuesFromAdjList.containsKey(j);
        if (hasKey) {
          copyCompleterValuesFromAdjList[j] =
              copyCompleterValuesFromAdjList[j]! + 1;
        } else {
          copyCompleterValuesFromAdjList[j] = 1;
        }
      }
    }
    for (var i in tree.adjacencyDict.entries) {
      final childId = i.key.child;
      final hasKey = copyCompleterValuesFromAdjDict.containsKey(childId);
      if (hasKey) {
        copyCompleterValuesFromAdjDict[childId] =
            copyCompleterValuesFromAdjDict[childId]! + 1;
      } else {
        copyCompleterValuesFromAdjDict[childId] = 1;
      }
    }
    // Сравнение значений с текущим комплиетром
    for (var i in copyCompleterValuesFromAdjList.entries) {
      assert(
        copyCompleterValuesFromAdjDict[i.key] == i.value,
      );
    }
    for (var i in copyCompleterValuesFromAdjDict.entries) {
      final maxVal = tree.inputCompleter[i.key]!.getMaxInputCount();
      assert(maxVal == i.value);
      //assert(copyCompleterValuesFromAdjDict[i.key] == maxVal);
    }

    // Тестовый прямой проход. Ловится ошибка зацикленности
    if (needForward) {
      tree.forward(List.generate(tree.input, (index) => Random().nextDouble()));
    }

    assert(tree.edges.length == tree.adjacencyDict.length);
  }

  @override
  List<double> forward(List<double> inp) {
    /*
      Ради эксперимента и более читабельного кода отказался от рекурсивного
      алгоритма. Возможно, в будущем для сравнения будет добавлен и рекурсивный
      алгоритм
    */
    _test(tree: this, needForward: false);
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
    // needForward false, что бы избавиться от зацкленности
    _test(needForward: false, tree: this);
    return resultVector;
  }

  /// Проверить дерево на предмет зацикливаний
  /// Начинается обход от каждого узла. Если по дереву можно добраться
  /// до самого себя - дерево зациклено. Это довольно долгая опрерация, так
  /// как приходится делать обход от каждого узла
  /// в будущем стоит придумать что-то получше и побыстрее
  bool _treeCorrect({required TreeV1 tree}) {
    for (var i in tree.nodesMap.keys) {
      final newContext =
          _CycleFindBypassContext(currentNodeId: i, visitedNodes: []);
      final res =
          _checkTreeCyclesBypass(nodeId: i, context: newContext, tree: tree);
      if (!res) {
        return false;
      }
    }
    return true;
  }

  bool _checkTreeCyclesBypass(
      {required int nodeId,
      required _CycleFindBypassContext context,
      required TreeV1 tree}) {
    context.addRec();
    context.visitedNodes.add(nodeId);

    for (var nextNodeId in tree.adjacencyList[nodeId]!) {
      // Если удалось по дереву добраться до начального узла - дерево зациклено
      if (nextNodeId == context.currentNodeId) {
        return false;
      }
      if (context.visitedNodes.contains(nextNodeId)) {
        continue;
      }
      final res = _checkTreeCyclesBypass(
          nodeId: nextNodeId, context: context, tree: tree);
      if (!res) {
        return false;
      }
    }
    return true;
  }

  ///// Удалить ребро
  /*bool deleteEdge(int e) {

    if (!edgesMap.containsKey(e)) {
      return false;
    }
    final currentKey = edgesMap[e]!;
    // При удалении ребра, учитывается:
    // 1) Удалить ключ из словаря смежностей
    // 2) Нужно удалить ссылку parent узла на child
    // 3) Поменять startState у узлов

    _test();
    return false;
  }*/

  /// Изменить параетры узла
  @override
  bool changeNode(int nodeId) {
    if (nodeId < input+output) {
      // Нельзя изменять входные и выходные узлы
      return false;
    }
    final hasNode = nodesMap.containsKey(nodeId);
    if (!hasNode) {
      throw Exception();
      return false;
    }

    nodesMap[nodeId]!.mutate();
    return true;
  }

  /// Изменить параметры ребра
  @override
  bool changeEdge(int edgeId) {
    final hasEdge = edgesMap.containsKey(edgeId);
    if (!hasEdge) {
      throw Exception();
    }
    edgesMap[edgeId]!.mutate();
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
    if (n1 >= input && n1 < output + input) {
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
    final treeCorrect = _treeCorrect(tree: this);
    if (!treeCorrect) {
      // Сброс
      adjacencyDict.remove(newKey);
      edgesMap.remove(edge.getId());
      edges.removeWhere((element) => element.getId() == edge.getId());
      adjacencyList[n1]!.removeWhere((element) => element == n2);
      inputCompleter[n2]!.addMaxCount(-1);
      nodesStartState[n2] = lastState;
      _test(tree: this);
      return false;
    }
    _test(tree: this);
    return true;
  }

  /// Удалить узел [nodeID] и все связи с этим узлом
  @override
  bool deleteNode(int nodeID) {
    return _deleteNode(nodeId: nodeID, tree: this);
  }

  static bool _deleteNode({required int nodeId, required TreeV1 tree}) {
    if (nodeId < tree.input + tree.output) {
      throw Exception("Нельзя удалить входные/выходные узлы");
    }

    final deletedNode = tree.nodesMap[nodeId];
    if (deletedNode == null) {
      throw Exception();
    }

    // Нужно удалить все связи между текущим и следующими узлами
    // У следующих узлов изменить inputCompleter
    // Удалить связи с предыдущими узлами
    // У предыдущих удалить ссылку на текущий

    // ---- Обработка следующих узлов
    final children = tree.adjacencyList[nodeId]!;
    final adjKeysWithNext = children
        .map((e) => AdjacencyDictKey(child: e, parent: nodeId))
        .toList();
    for (var nextNode in children) {
      tree.inputCompleter[nextNode]!.addMaxCount(-1);
    }
    for (var k in adjKeysWithNext) {
      final edgeId = tree.adjacencyDict[k]?.getId();
      if (edgeId == null) {
        throw Exception();
      }
      tree.edges.removeWhere((element) => element.getId() == edgeId);
      final res = tree.edgesMap.remove(edgeId);
      if (res == null) {
        throw Exception();
      }
      final delRes = tree.adjacencyDict.remove(k);
      if (delRes == null) {
        throw Exception();
      }
    }

    // ---- Обработка предыдущих узлов
    List<int> parents = tree.adjacencyDict.keys
        .map((e) {
          if (e.child == nodeId) {
            return e.parent;
          }
          return -1;
        })
        .toList()
        .where((element) => element != -1)
        .toList();
    final parentsKeys = parents.map((e) => AdjacencyDictKey(child: nodeId, parent: e));
    for(var i in parents) {
      final res = tree.adjacencyList[i]!.remove(nodeId);
      if (!res) {
        throw Exception();
      }
    }
    for(var k in parentsKeys) {
      final edgeId = tree.adjacencyDict[k]?.getId();
      if (edgeId == null) {
        throw Exception();
      }
      tree.edges.removeWhere((element) => element.getId() == edgeId);
      final res = tree.edgesMap.remove(edgeId);
      if (res == null) {
        throw Exception();
      }
      final delRes = tree.adjacencyDict.remove(k);
      if (delRes == null) {
        throw Exception();
      }
    }

    tree.nodes.removeWhere((element) => element.getId() == nodeId);
    final r1 = tree.nodesMap.remove(nodeId);
    final r2 = tree.inputCompleter.remove(nodeId);
    final r3 = tree.nodesStartState.remove(nodeId);
    final r4 = tree.adjacencyList.remove(nodeId);
    assert(r1 != null);
    assert(r2 != null);
    assert(r3 != null);
    assert(r4 != null);

    _test(tree: tree);
    return true;
  }

  /// Удалить связь [edgeId]
  @override
  bool deleteEdge(int edgeId) {
    return _deleteEdge(edgeId: edgeId, tree: this);
  }

  /// Удалить связь [edgeId] из дерева [tree]
  static bool _deleteEdge({required int edgeId, required TreeV1 tree}) {
    if (tree.edges.isEmpty) {
      return false;
    }

    final hasEdge = tree.edgesMap.containsKey(edgeId);
    if (!hasEdge) {
      throw Exception();
    }

    // Ключ смежностей, связанный с эти ребром
    AdjacencyDictKey? currentKey;

    for (var i in tree.adjacencyDict.entries) {
      if (i.value.getId() == edgeId) {
        currentKey = i.key;
      }
    }
    assert(currentKey != null);

    final parent = currentKey!.parent;
    final child = currentKey.child;

    assert(tree.inputCompleter[child]!.maxInputsCount > 0);
    assert(tree.adjacencyList[parent]!.contains(child));

    tree.inputCompleter[child]!.addMaxCount(-1);
    tree.adjacencyList[parent]!.remove(child);

    tree.adjacencyDict.remove(currentKey);
    tree.edges.removeWhere((element) => element.getId() == edgeId);
    tree.edgesMap.remove(edgeId);

    _test(tree: tree);

    return true;
  }

  @override
  bool addNewNextNode(int current, TreeNodeBase node, TreeEdgeBase edge) {
    /* current -> edge -> node */
    if (current >= input && current < output + input) {
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
    _test(tree: this);
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
    _test(tree: this);
    return true;
  }

  @override
  bool addNodeBetween(
      int n1, int n2, TreeNodeBase n, TreeEdgeBase e1, TreeEdgeBase e2) {
    // n1 -> e1 -> n -> e2 -> n2

    // Делается попытка сделать изменения на снапшоте
    final snapshot = deepCopy() as TreeV1;
    final result =
        _addNodeBetween(tree: snapshot, n1: n1, n2: n2, n: n, e1: e1, e2: e2);
    if (!result) {
      return false;
    }
    // Только после успешного добавление в снапшоте, добавяем в текущее дерево
    final resultThis =
        _addNodeBetween(tree: this, n1: n1, n2: n2, n: n, e1: e1, e2: e2);
    if (!resultThis) {
      throw Exception();
    }
    _test(tree: this);
    return true;
  }

  /// Добавить узел между. Метод не привязывется к конкретному дереву и передаётся в
  /// параметре tree. Обычно, это может быть либо this, либо snapshot для
  /// тестирования зацикленностей в дереве после добавления новых связей
  bool _addNodeBetween(
      {required TreeV1 tree,
      required int n1,
      required int n2,
      required TreeNodeBase n,
      required TreeEdgeBase e1,
      required TreeEdgeBase e2}) {
    if (n1 < tree.input && n2 < tree.input) {
      //throw Exception("Запрещено добавлять связи между входными узлами");
      return false;
    }
    if (n2 < tree.input) {
      //throw Exception("Запрещено добавлять связи к входному узлу");
      return false;
    }
    if (n1 >= tree.input && n2 <= tree.output) {
      //throw Exception("Запрещено добавлять связь от выходного узла");
      return false;
    }
    if (tree.nodesStartState[n2]!) {
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

    final hasFirstNode = tree.nodesMap.containsKey(n1);
    final hasSecondNode = tree.nodesMap.containsKey(n2);
    final hasNewNode = tree.nodesMap.containsKey(newNodeID);

    final hasFirstEdge = tree.edgesMap.containsKey(firstEdgeID);
    final hasSecondEdge = tree.edgesMap.containsKey(secondEdgeID);

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

    if (tree.adjacencyDict.containsKey(firstKey) ||
        tree.adjacencyDict.containsKey(secondKey)) {
      throw Exception();
    }

    tree.nodes.add(n);
    tree.nodesMap[newNodeID] = n;

    tree.edges.add(e1);
    tree.edges.add(e2);
    tree.edgesMap[firstEdgeID] = e1;
    tree.edgesMap[secondEdgeID] = e2;

    // Существовала ли связь между n1->n2 или n2->n1
    final currentEdgeExists = tree.adjacencyDict.containsKey(currentKey);

    // Если связь существовала, нужно определить направление связи
    // true - n1 -> n2
    // false - n2 -> n1
    // null - связи нет
    bool? currentEdgeDir;

    if (currentEdgeExists) {
      final deletedEdgeId = tree.adjacencyDict[currentKey]!.getId();
      if (tree.adjacencyList[n1]!.contains(n2)) {
        // n1 -> n2 . Проверка невозможности n2 -> n1
        if (tree.adjacencyList[n2]!.contains(n1)) {
          throw Exception();
        }
        assert(!nodesStartState[n2]!);
        tree.inputCompleter[n2]!.addMaxCount(-1);
        tree.adjacencyList[n1]!.remove(n2);
        tree.adjacencyDict.remove(currentKey);
      } else if (tree.adjacencyList[n2]!.contains(n1)) {
        // n2 -> n1 . Проверка невозможности n1 -> n2
        if (tree.adjacencyList[n1]!.contains(n2)) {
          throw Exception();
        }
        assert(!tree.nodesStartState[n1]!);
        tree.inputCompleter[n1]!.addMaxCount(-1);
        tree.adjacencyList[n2]!.remove(n1);
        tree.adjacencyDict.remove(currentKey);
      } else {
        throw Exception();
      }

      // Удалить ребро
      tree.edges.removeWhere((element) => element.getId() == deletedEdgeId);
      tree.edgesMap.remove(deletedEdgeId);
    } else {
      currentEdgeDir = null;
    }

    tree.nodesStartState[n2] = false;
    tree.inputCompleter[n2]!.addMaxCount(1);

    tree.adjacencyList[n1]!.add(newNodeID);

    assert(tree.inputCompleter[newNodeID] == null);
    assert(tree.adjacencyList[newNodeID] == null);

    tree.inputCompleter[newNodeID] = NodesInputCounter.empty();
    tree.inputCompleter[newNodeID]!.addMaxCount(1);

    tree.adjacencyList[newNodeID] = [];
    tree.adjacencyList[newNodeID]!.add(n2);

    tree.nodesStartState[newNodeID] = false;

    tree.adjacencyDict[firstKey] = e1;
    tree.adjacencyDict[secondKey] = e2;

    final treeCorrect = _treeCorrect(tree: tree);

    if (treeCorrect) {
      _test(tree: tree);
      return true;
    } else {
      return false;
    }
  }

  @override
  String toString() {
    print('ALL NODES:');
    for (var i in nodes) {
      print('Node id = ${i.getId()}');
    }
    print('ALL EDGES:');
    for (var i in edges) {
      print('Edge id = ${i.getId()}');
    }
    print('ADJACENCY DICT:');
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
    for (var i in nodesStartState.entries) {
      print('Node - ${i.key}, is start - ${i.value}');
    }
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

  @override
  List<int> getEdgesId() {
    return edges.map((e) => e.getId()).toList();
  }
}

/// Вспомогательный класс, который хранит сколько всего есть входов в узел
/// и сколько на данный момент входов завершено

// todo Тесты на коллизии ключей
@JsonSerializable()
class NodesInputCounter {
  int maxInputsCount = 0;
  final List<double> currentInputs;

  NodesInputCounter(
      {required this.currentInputs, required this.maxInputsCount});

  factory NodesInputCounter.fromJson(Map<String, dynamic> json) =>
      _$NodesInputCounterFromJson(json);

  Map<String, dynamic> toJson() => _$NodesInputCounterToJson(this);

  factory NodesInputCounter.empty() {
    return NodesInputCounter(currentInputs: [], maxInputsCount: 0);
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
    return NodesInputCounter(
        currentInputs: currentInputs, maxInputsCount: maxInputsCount);
  }
}

/// Вспомогательный класс-контекст для обхода дерева при поиске зацикливаний
class _CycleFindBypassContext {
  int recCounter = 0;
  int currentNodeId;
  List<int> visitedNodes;

  _CycleFindBypassContext(
      {required this.currentNodeId, required this.visitedNodes});

  void addRec() {
    if (recCounter > 10000) {
      throw Exception();
    }
    recCounter++;
  }
}
