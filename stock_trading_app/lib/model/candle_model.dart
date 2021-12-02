class CandleModel {
  final int close;
  final int high;
  final int low;
  final int volume;
  final int open;
  final int time;

  CandleModel(
      {required this.close,
      required this.open,
      required this.high,
      required this.low,
      required this.volume,
      required this.time});
}
