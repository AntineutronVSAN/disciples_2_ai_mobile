


import 'dart:math';

class PairValues<T> {
  T first;
  T end;
  PairValues({ required this.first, required this.end});
}

int randomBetween(int start, int end, Random random) {
  if (start > end) {
    throw Exception();
  }
  return random.nextInt(end - start) + start;

}

int randomRanges(List<PairValues<int>> ranges, Random random) {

  final rangeRandomValues = [];
  for(var i in ranges) {
    if (i.first > i.end) {
      throw Exception();
    }
    if (i.end == i.first) {
      continue;
    }
    rangeRandomValues.add(randomBetween(i.first, i.end, random));
  }
  final randomIndex = random.nextInt(rangeRandomValues.length);
  return rangeRandomValues[randomIndex];

}

