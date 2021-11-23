import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class TestPage2 extends StatefulWidget {
  const TestPage2({Key? key}) : super(key: key);

  @override
  _TestPage2State createState() => _TestPage2State();
}

class _TestPage2State extends State<TestPage2> {
  Future<List<Candle>> getdata() async {
    List<Candle> candles = [];
    int a = (DateTime.now().millisecondsSinceEpoch / 1000.0).toInt();
    print(a);
    var response = await http.get(Uri.parse(
        "https://finnhub.io/api/v1/stock/candle?symbol=AAPL&resolution=D&from=1606126034&to=$a&token=c6av1iaad3ieq36s0q9g"));
    var data = json.decode(response.body);
    // print("${data["o"].length} , ${data["c"].length},${data["h"].length}");

    for (int i = data["o"].length - 1; i >= 0; i--) {
      final date = DateTime.fromMillisecondsSinceEpoch(data["t"][i] * 1000);
      // print(date);.
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

  @override
  Widget build(BuildContext context) {
    List<Candle> candles = [];
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Page 2'),
      ),
      body: Center(
        child: AspectRatio(
            aspectRatio: 1.2,
            child: FutureBuilder(
                future: getdata(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Candle>> snapshot) {
                  if (snapshot.hasData) {
                    print(snapshot.data);
                    return Candlesticks(
                      onIntervalChange: (String value) async {
                        print("sda");
                      },
                      candles: snapshot.data!,
                      interval: "1d",
                    );
                  }
                  print("did not get data");
                  return Container();
                })),
      ),
    );
  }
}
