import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<Candle> candles = [];
  WebSocketChannel? _channel;

  String interval = "1m";

  void binanceFetch(String interval) {
    if (_channel != null) _channel!.sink.close();
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://ws.finnhub.io?token=c6av1iaad3ieq36s0q9g'),
    );
    _channel!.sink.add('{"type": "subscribe", "symbol": "BINANCE:BTCUSDT"}');
  }

  @override
  void initState() {
    binanceFetch("1m");
    super.initState();
  }

  @override
  void dispose() {
    if (_channel != null) _channel!.sink.close();
    super.dispose();
  }

  void updateCandlesFromSnapshot(AsyncSnapshot<Object?> snapshot) {
    if (snapshot.data != null) {
      final data = jsonDecode(snapshot.data as String) as Map<String, dynamic>;
      if (data.containsKey("k") == true &&
          candles[0].date.millisecondsSinceEpoch == data["k"]["t"]) {
        candles[0] = Candle(
            date: candles[0].date,
            high: double.parse(data["k"]["h"]),
            low: double.parse(data["k"]["l"]),
            open: double.parse(data["k"]["o"]),
            close: double.parse(data["k"]["c"]),
            volume: double.parse(data["k"]["v"]));
      } else if (data.containsKey("k") == true &&
          data["k"]["t"] - candles[0].date.millisecondsSinceEpoch ==
              candles[0].date.millisecondsSinceEpoch -
                  candles[1].date.millisecondsSinceEpoch) {
        candles.insert(
            0,
            Candle(
                date: DateTime.fromMillisecondsSinceEpoch(data["k"]["t"]),
                high: double.parse(data["k"]["h"]),
                low: double.parse(data["k"]["l"]),
                open: double.parse(data["k"]["o"]),
                close: double.parse(data["k"]["c"]),
                volume: double.parse(data["k"]["v"])));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("candleSticks"),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1.2,
          child: StreamBuilder(
            stream: _channel == null ? null : _channel!.stream,
            builder: (context, snapshot) {
              updateCandlesFromSnapshot(snapshot);
              return Candlesticks(
                onIntervalChange: (String value) async {
                  binanceFetch(value);
                },
                candles: candles,
                interval: interval,
              );
            },
          ),
        ),
      ),
    );
  }
}
