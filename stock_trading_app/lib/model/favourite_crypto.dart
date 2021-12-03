import 'package:hive/hive.dart';
part 'favourite_crypto.g.dart';

@HiveType(typeId: 1)
class Favourite {
  @HiveField(0)
  String description;
  @HiveField(1)
  String displaySymbol;
  @HiveField(2)
  String symbol;
  Favourite(
      {required this.description,
      required this.displaySymbol,
      required this.symbol});
}
