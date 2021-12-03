class StockSymbol {
  late String description;
  late String displaySymbol;
  late String symbol;

  StockSymbol({
    required this.description,
    required this.displaySymbol,
    required this.symbol,
  });

  StockSymbol.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    displaySymbol = json['displaySymbol'];
    symbol = json['symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['description'] = description;
    data['displaySymbol'] = displaySymbol;
    data['symbol'] = symbol;
    return data;
  }
}
