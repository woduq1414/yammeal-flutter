import "dart:math";

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Iterable<E> mapIndexed<E, T>(
    Iterable<T> items, E Function(int index, T item) f) sync* {
  var index = 0;

  for (final item in items) {
    yield f(index, item);
    index = index + 1;
  }
}

String getRandomPushTitle(){


  var list = ["오늘도 상쾌한 하루!", "오늘 점심 뭐 나와?", "오늘 좀 맛있겠네ㅋㅋ", "오늘 뭐 나오는지 볼까?"];

// generates a new Random object
  final _random = new Random();

// generate a random index based on the list length
// and use it to retrieve the element
  var element = list[_random.nextInt(list.length)];

  return element;
}

dynamic getRandomElement(List list){


// generates a new Random object
  final _random = new Random();

// generate a random index based on the list length
// and use it to retrieve the element
  var element = list[_random.nextInt(list.length)];

  return element;
}


getFromStorage(String key) async {
  final storage = new FlutterSecureStorage();
  var value = await storage.read(key: key);
  return value;
}


bool isSameDate(DateTime a, DateTime b){
  if(a.year == b.year && a.month == b.month && a.day == b.day){
    return true;
  }else{
    return false;
  }
}