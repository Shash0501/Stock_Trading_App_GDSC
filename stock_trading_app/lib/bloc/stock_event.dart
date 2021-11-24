part of 'stock_bloc.dart';

@immutable
abstract class StockEvent {}

class getstocksymbolsEvent extends StockEvent {}

class getCangleGraphEvent extends StockEvent {}
