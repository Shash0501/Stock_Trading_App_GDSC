part of 'stock_bloc.dart';

@immutable
abstract class StockState extends Equatable {}

class StockInitial extends StockState {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class Loading extends StockState {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class StockSymbolsLoaded extends StockState {
  List<CryptoSymbol> stocks;
  StockSymbolsLoaded({required this.stocks});
  @override
  // TODO: implement props
  List<Object?> get props => [stocks];
}
