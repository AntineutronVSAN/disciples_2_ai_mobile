


abstract class TreeEdgeBase {

  Map<String, dynamic> toJson();
  TreeEdgeBase.fromJson(Map<String, dynamic> json);
  int getId();
  double getWeight();
  void setWeight(double val);

  double calculate(double input);
}