
import 'package:json_annotation/json_annotation.dart';

part 'adjacency_dict.g.dart';

// todo Тесты на коллизии ключей
@JsonSerializable()
class AdjacencyDictKey {
  final int parent;
  final int child;
  AdjacencyDictKey({required this.child, required this.parent});

  factory AdjacencyDictKey.fromJson(Map<String, dynamic> json) =>
      _$AdjacencyDictKeyFromJson(json);
  Map<String, dynamic> toJson() => _$AdjacencyDictKeyToJson(this);

  @override
  bool operator ==(Object other) {

    final k = other as AdjacencyDictKey;

    return (k.parent == parent && k.child == child)
        || (k.child == parent && k.child == parent);

  }

  @override
  // TODO: implement hashCode
  int get hashCode => parent.hashCode ^ child.hashCode;


  @override
  String toString() {
    return 'Adjacency key. Parent - $parent Child - $child';
  }

  AdjacencyDictKey deepCopy() {
    return AdjacencyDictKey(child: child, parent: parent);
  }
}