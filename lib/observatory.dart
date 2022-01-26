

class PerfomanceObservatory {

  static int unitCopyCounter = 0;


  static void addUnitCopyCount() {
    unitCopyCounter++;
    print('Счётчик копирований юнита ------> $unitCopyCounter');
  }
}