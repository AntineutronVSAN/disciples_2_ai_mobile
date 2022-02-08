
abstract class GameObjectsProviderBaseV2 {
  final Map<String, Map<String, dynamic>> objectsMap = {};
  final List<Map<String, dynamic>> objects = [];
  bool inited = false;

  /// Подгрузка и инициализация провайдера
  Future<void> init();


  /*List<Map<String, dynamic>> get objects {
    if (!inited) {
      throw Exception();
    }
    return _objects;
  }

  Map<String, Map<String, dynamic>> get objectsMap {
    if (!inited) {
      throw Exception();
    }
    return _objectsMap;
  }*/

  List<Map<String, dynamic>> getObjects() {
    if (!inited) {
      throw Exception();
    }
    return objects;
  }
  Map<String, Map<String, dynamic>> getObjectsMap() {
    if (!inited) {
      throw Exception();
    }
    return objectsMap;
  }
}