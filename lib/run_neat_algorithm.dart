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
      initFrom: false);

  tree.addNewNextNode(
    0,
    NodeV1.random(IdCalculator.getNextId()),
    EdgeV1.random(IdCalculator.getNextId()),
  );
  tree.addNewNextNode(
    1,
    NodeV1.random(IdCalculator.getNextId()),
    EdgeV1.random(IdCalculator.getNextId()),
  );
  tree.addNewNextNode(
    2,
    NodeV1.random(IdCalculator.getNextId()),
    EdgeV1.random(IdCalculator.getNextId()),
  );
  tree.addNewNextNode(
    3,
    NodeV1.random(IdCalculator.getNextId()),
    EdgeV1.random(IdCalculator.getNextId()),
  );

  tree.addNodeBetween(
      0,
      20,
      NodeV1.random(IdCalculator.getNextId()),
      EdgeV1.random(IdCalculator.getNextId()),
      EdgeV1.random(IdCalculator.getNextId()));

  tree.addNewPrevNode(
      22,
      NodeV1.random(IdCalculator.getNextId()),
      EdgeV1.random(IdCalculator.getNextId())
  );


  print(tree);

  //final inputVector = List.generate(10, (index) => Random().nextDouble());

  //final result = tree.forward(inputVector);

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
