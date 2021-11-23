import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TestPage3 extends StatefulWidget {
  const TestPage3({Key? key}) : super(key: key);

  @override
  _TestPage3State createState() => _TestPage3State();
}

class _TestPage3State extends State<TestPage3> {
  Future<List<Candle>> getdata() async {
    List<Candle> candles = [];
    String a = DateTime.now().millisecondsSinceEpoch.toString();
    print(a);
    var response = await http.get(Uri.parse(
        "https://finnhub.io/api/v1/stock/candle?symbol=AAPL&resolution=1&from=1631022248&to=1631627048&token=c6av1iaad3ieq36s0q9g"));
    var data = json.decode(response.body);
    // print("${data["o"].length} , ${data["c"].length},${data["h"].length}");

    for (int i = data["o"].length - 1; i >= 0; i--) {
      final date = DateTime.fromMillisecondsSinceEpoch(data["t"][i] * 1000);
      candles.add(Candle(
          open: data["o"][i].toDouble(),
          high: data["h"][i].toDouble(),
          low: data["l"][i].toDouble(),
          close: data["c"][i].toDouble(),
          volume: (data["v"][i]).toDouble(),
          date: date));
    }

    return (candles);
  }

  void _listen() {
    channel.sink.add('{"type": "subscribe", "symbol": "BINANCE:BTCUSDT"}');
  }

  void _closeschannel() {
    channel.sink.close();
  }

  final channel = WebSocketChannel.connect(
    Uri.parse('wss://ws.finnhub.io?token=c6av1iaad3ieq36s0q9g'),
  );
  @override
  Widget build(BuildContext context) {
    _listen();
    List<Candle> candles = [];
    return Scaffold(
      appBar: AppBar(
        title: Text("Testing...."),
      ),
      body: FutureBuilder(
          future: getdata(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Candle>> snapshot) {
            if (snapshot.hasData) {
              return StreamBuilder(
                  stream: channel.stream,
                  builder: (context, data) {
                    snapshot.hasData ? print('${data}') : print("null");
                    return AspectRatio(
                      aspectRatio: 1.2,
                      child: Candlesticks(
                        onIntervalChange: (String value) async {
                          print(value);
                        },
                        candles: snapshot.data!,
                        interval: "1d",
                      ),
                    );
                  });
            }
            print("did not get data");
            return Container();
          }),
    );
  }
}
