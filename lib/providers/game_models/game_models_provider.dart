

abstract class GameObjectsProviderBaseV2<T> {
  final Map<String, T> objectsMap = {};
  final List<T> objects = [];

  /// Подгрузка и инициализация провайдера
  Future<void> init();

  List<T> getObjects() {
    return objects;
  }
  Map<String, T> getObjectsMap() {
    return objectsMap;
  }
}