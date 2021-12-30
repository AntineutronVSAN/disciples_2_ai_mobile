

abstract class TreeNodeBase {

  int getId();
  String getActivation();
  void setActivation(String activation);
  double calculate(List<double> input);

  Map<String, dynamic> toJson();
  TreeNodeBase.fromJson(Map<String, dynamic> json);


  TreeNodeBase deepCopy();
}