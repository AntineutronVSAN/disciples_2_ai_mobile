

import 'package:d2_ai_v2/optim_algorythm/neat/edge_base.dart';

import '../base.dart';
import 'id_calculator.dart';
import 'node_base.dart';

abstract class GameTreeBase implements AiAlgorithm {

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

  bool changeNode(int nodeId);
  bool changeEdge(int edgeId);

  @override
  List<double> forward(List<double> inp);

  List<int> getNodesId();
  List<int> getEdgesId();

  IdCalculator getIdCalculator();

  GameTreeBase deepCopy();

}