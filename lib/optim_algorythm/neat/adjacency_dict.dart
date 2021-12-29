

// todo Тесты на коллизии ключей
class AdjacencyDictKey {
  final int parent;
  final int child;
  AdjacencyDictKey({required this.child, required this.parent});

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
}