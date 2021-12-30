
import 'base.dart';

abstract class IndividualBase {

  IndividualBase cross(IndividualBase target);
  void mutate();

  double getFitness();
  void setFitness(double fitness);
  List<double> getFitnessHistory();

  IndividualBase copyWith();

  Map<String, dynamic> toJson();
  IndividualBase.fromJson(Map<String, dynamic> json);

  AiAlgorithm getAlgorithm();

  int getAlgorithmVersion();
}