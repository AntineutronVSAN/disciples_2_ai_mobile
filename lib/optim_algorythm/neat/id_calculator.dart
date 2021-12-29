


class IdCalculator {
  static int currentId = -1;

  static void setStartID(int id) {
    currentId = id;
  }

  static int getNextId() {
    currentId++;
    return currentId;
  }

  static int fromID(int id) {
    assert(id > currentId);
    currentId = id;
    return id;
  }
}