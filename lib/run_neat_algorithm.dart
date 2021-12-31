import 'dart:math';

import 'package:d2_ai_v2/optim_algorythm/neat/adjacency_dict.dart';
import 'package:d2_ai_v2/optim_algorythm/neat/id_calculator.dart';
import 'package:d2_ai_v2/optim_algorythm/neat/trees/tree_v1.dart';

import 'optim_algorythm/neat/edges/edge_v1.dart';
import 'optim_algorythm/neat/nodes/node_v1.dart';

void main() async {
  await startNeatAlgorithm();
}

Future<void> startNeatAlgorithm() async {
  final tree = TreeV1(
      input: 10,
      output: 10,
      nodes: [],
      nodesMap: {},
      edges: [],
      edgesMap: {},
      adjacencyDict: {},
      adjacencyList: {},
      initFrom: false,
      idCalculator: null,
    nodesStartState: {},
    inputCompleter: {},
  );

  //NodeV1.random(IdCalculator.getNextId()),
  //EdgeV1.random(IdCalculator.getNextId()),

  //final tn = NodeV1.random(IdCalculator.getNextId());
  //final te = EdgeV1.random(IdCalculator.getNextId());

  NodeV1 tn() {
    return NodeV1.random(tree.getIdCalculator().getNextId());
  }
  EdgeV1 te() {
    return EdgeV1.random(tree.getIdCalculator().getNextId());
  }

  //tree.addEdge(0, 10, EdgeV1.random(IdCalculator.getNextId()));
  /*tree.addNewNextNode(0, tn(), te()); // ID = 20
  tree.addNewNextNode(20, tn(), te()); // ID = 22
  tree.addNewNextNode(22, tn(), te()); // ID = 24
  tree.addNewNextNode(24, tn(), te()); // ID = 26
  tree.addNewPrevNode(20, tn(), te()); // ID = 28
  tree.addNewPrevNode(20, tn(), te()); // ID = 30
  tree.addNewNextNode(20, tn(), te()); // ID = 32
  tree.addEdge(28, 30, te());*/

  print(tree);

  final inputVector = List.generate(10, (index) => Random().nextDouble());

  var result = tree.forward(inputVector);
  print(result);
  result = tree.forward(inputVector);
  print(result);
  /*final adjDict = <AdjacencyDictKey, bool>{};
  final k1 = AdjacencyDictKey(child: 1, parent: 0);
  final k2 = AdjacencyDictKey(child: 0, parent: 1);
  final k3 = AdjacencyDictKey(child: 5, parent: 1);
  adjDict[k1] = true;
  print(k1 == k2);
  print(k2 == k3);
  print('asdfasdf');
  print(adjDict[k2]);
  print(adjDict[k3]);*/
}
