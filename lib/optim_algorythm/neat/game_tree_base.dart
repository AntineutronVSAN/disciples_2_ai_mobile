

import 'package:d2_ai_v2/optim_algorythm/neat/edge_base.dart';

import 'node_base.dart';

abstract class GameTreeBase {

  /// Добавить новый узел [node] с новой связью [edge] от узла [current]
  bool addNewNextNode(int current, TreeNodeBase node, TreeEdgeBase edge);

  /// Добавить новый узел [node] с связью [edge] к узлу [target]
  bool addNewPrevNode(int target, TreeNodeBase node, TreeEdgeBase edge);

  /// Связать два существующих узла [n1] и [n2] связью [edge]
  bool addEdge(int n1, int n2, TreeEdgeBase edge);

  /// Добавить новый узел [n] между двумя существующими узлами [n1] и [n2] со связями [e1] и [e2]
  bool addNodeBetween(
      int n1,
      int n2,
      TreeNodeBase n,
      TreeEdgeBase e1,
      TreeEdgeBase e2);

  List<double> forward(List<double> inp);
}