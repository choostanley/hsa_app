extension RD on DateTime{

  DateTime roundDown({Duration delta = const Duration(minutes: 15)}){
    return DateTime.fromMillisecondsSinceEpoch(
        millisecondsSinceEpoch -
        millisecondsSinceEpoch % delta.inMilliseconds
    );
  }
}