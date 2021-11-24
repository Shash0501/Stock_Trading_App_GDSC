class StockSymbol {
  late String currency;
  late String description;
  late String displaySymbol;
  late String figi;
  late String mic;
  late String symbol;
  late String type;

  StockSymbol(
      {required this.currency,
      required this.description,
      required this.displaySymbol,
      required this.figi,
      required this.mic,
      required this.symbol,
      required this.type});

  StockSymbol.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    description = json['description'];
    displaySymbol = json['displaySymbol'];
    figi = json['figi'];
    mic = json['mic'];
    symbol = json['symbol'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currency'] = this.currency;
    data['description'] = this.description;
    data['displaySymbol'] = this.displaySymbol;
    data['figi'] = this.figi;
    data['mic'] = this.mic;
    data['symbol'] = this.symbol;
    data['type'] = this.type;
    return data;
  }
}
