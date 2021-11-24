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
  List<Candle> candles = [];
  List<double> points = [];
  double volume = 0;
  late int last_updated;
  Future<List<Candle>> getdata() async {
    int a = DateTime.now().millisecondsSinceEpoch;
    a = a ~/ 1000;
    last_updated = a;

    var response = await http.get(Uri.parse(
        "https://finnhub.io/api/v1/stock/candle?symbol=BINANCE:BTCUSDT&resolution=1&from=1637724307&to=$a&token=c6av1iaad3ieq36s0q9g"));
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

  printcandledata(Candle candle) {
    print(candle.open);
    print(candle.high);
    print(candle.low);
    print(candle.close);
    print(candle.volume);
    print(candle.date);
  }

  bool addtocandle(var a) {
    // print(a);
    // print(candles.length);
    var data = json.decode(a);
    // print(
    //     "====================================================================================");
    var last1 =
        data["data"] != null ? data["data"][data["data"].length - 1] : "exit";

    if (last1 == "exit") {
      return false;
    }
    // print(data["data"].last["t"]);
    // print(last_updated);
    // print((data["data"].last["t"] / 1000).toDouble() - last_updated.toDouble());
    print((data["data"].last["t"] / 1000).toDouble() - last_updated.toDouble());
    if ((data["data"].last["t"] / 1000).toDouble() - last_updated.toDouble() <=
        60) {
      points.add(data["data"].last["p"].toDouble());
      volume += data["data"].last["v"].toDouble();
      double high = data["data"].last["p"].toDouble() > candles[0].high
          ? data["data"].last["p"].toDouble()
          : candles[0].high;
      double low = data["data"].last["p"].toDouble() < candles[0].low
          ? data["data"].last["p"].toDouble()
          : candles[0].low;
      Candle candle = Candle(
          close: data["data"].last["p"].toDouble(),
          open: candles[0].open,
          high: high,
          low: low,
          date: candles[0].date,
          volume: volume);
      candles.removeAt(0);
      candles.insert(0, candle);
      return true;
    } else {
      double close = points.last.toDouble();
      double open = points.first.toDouble();
      points.sort();
      double high = points.last.toDouble();
      double low = points.first.toDouble();
      print("printing the datetimne ");
      print(DateTime.fromMillisecondsSinceEpoch(data["data"].last["t"]));

      Candle candle = Candle(
          close: points.last,
          open: points.first,
          date: DateTime.fromMillisecondsSinceEpoch(data["data"].last["t"]),
          high: high,
          low: low,
          volume: volume);
      candles.insert(0, candle);
      points.clear();
      volume = 0;
      last_updated = (data["data"].last["t"] / 1000).toInt();
      return true;
      // print(points);
    }
    // if (data["data"].last["t"] - candles[0].date.millisecondsSinceEpoch <=
    //     60000) {
    //   var date = DateTime.fromMillisecondsSinceEpoch(last["t"]);
    //   Candle candle = Candle(
    //       close: candles[0].close,
    //       date: date,
    //       high: last["p"],
    //       low: candles[0].low,
    //       open: candles[0].open,
    //       volume: candles[0].volume + last["v"]);

    // printcandledata(candles[0]);
    // print("==================================");
    // printcandledata(candle);
    //   candles.removeAt(0);
    //   candles.insert(0, candle);
    //   // candles[0].date=DateTime.fromMillisecondsSinceEpoch(data["data"].last["t"]*1000);
    // } else {
    //   var date = DateTime.fromMillisecondsSinceEpoch(last["t"]);
    //   Candle candle = Candle(
    //       close: candles[0].close,
    //       date: date,
    //       high: last["p"],
    //       low: candles[0].low,
    //       open: candles[0].open,
    //       volume: candles[0].volume + last["v"]);
    //   print("candle added");
    // printcandledata(candles[0]);
    // print("==================================");
    // printcandledata(candle);
    // candles.removeAt(0);
    //   candles.insert(0, candle);
    // }
    for (var item in data["data"]) {
      // print((item["t"].toInt()));
    }
    return false;
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
  void dispose() {
    channel.sink.close();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _listen();
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
                  builder: (context, snapshot1) {
                    // print('${data}')
                    snapshot1.hasData
                        ? addtocandle(snapshot1.data)
                        : print("null");

                    ValueNotifier<int> _counter =
                        ValueNotifier<int>(candles.length);
                    print(_counter.value);
                    // print(.length);
                    if (snapshot1.hasData) {
                      if (addtocandle(snapshot1.data)) {
                        // print(candles[0]);
                        return AspectRatio(
                          aspectRatio: 1.2,
                          child: Candlesticks(
                            onIntervalChange: (String value) async {
                              print(value);
                            },
                            candles: candles,
                            interval: "1m",
                          ),
                        );
                      } else {
                        return AspectRatio(
                          aspectRatio: 1.2,
                          child: Candlesticks(
                            onIntervalChange: (String value) async {
                              print(value);
                            },
                            candles: snapshot.data!,
                            interval: "1m",
                          ),
                        );
                      }
                    }
                    return Container();
                  });
            }
            print("did not get data");
            return Container();
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _closeschannel,
        child: Icon(Icons.close),
      ),
    );
  }
}
