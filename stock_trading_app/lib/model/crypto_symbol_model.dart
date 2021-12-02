class CryptoSymbol {
  late String description;
  late String displaySymbol;
  late String symbol;

  CryptoSymbol({
    required this.description,
    required this.displaySymbol,
    required this.symbol,
  });

  CryptoSymbol.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    displaySymbol = json['displaySymbol'];
    symbol = json['symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['displaySymbol'] = this.displaySymbol;
    data['symbol'] = this.symbol;
    return data;
  }
}
