


class IdCalculator {
  int currentId = -1;

  void setStartID(int id) {
    currentId = id;
  }

  int getNextId() {
    currentId++;
    return currentId;
  }

  int fromID(int id) {
    assert(id > currentId);
    currentId = id;
    return id;
  }
}