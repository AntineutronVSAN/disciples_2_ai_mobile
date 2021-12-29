

import 'package:d2_ai_v2/dart_nural/neural_base.dart';

abstract class GeneticIndividBase {

  GeneticIndividBase cross(GeneticIndividBase target);
  void mutate();

  double getFitness();
  void setFitness(double fitness);
  List<double> getFitnessHistory();

  GeneticIndividBase copyWith();

  Map<String, dynamic> toJson();
  GeneticIndividBase.fromJson(Map<String, dynamic> json);

  GameNeuralNetworkBase getNn();

  List<List<double>> getWeights();
  List<List<double>> getBiases();
  List<List<String>> getActivations();

  int getNetworkVersion();
}