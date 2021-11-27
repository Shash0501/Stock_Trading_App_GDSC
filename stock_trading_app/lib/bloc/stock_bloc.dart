import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:stock_trading_app/model/crypto_symbol.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
part 'stock_event.dart';
part 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  StockBloc() : super(StockInitial()) {
    on<StockEvent>((event, emit) async {
      // TODO: implement event handler
      if (event is getstocksymbolsEvent) {
        try {
          emit(Loading());
          List<CryptoSymbol> stocks = [];
          var response = await http.get(Uri.parse(
              "https://finnhub.io/api/v1/crypto/symbol?exchange=binance&token=c6av1iaad3ieq36s0q9g"));
          var data = json.decode(response.body);
          for (int i = 0; i < 100; i++) {
            stocks.add(CryptoSymbol.fromJson(data[i]));
          }
          emit(StockSymbolsLoaded(stocks: stocks));
        } catch (e) {
          print("E");
        }
      }
    });
  }
}
