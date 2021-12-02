import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:stock_trading_app/constants.dart/resolution.dart';
import 'package:stock_trading_app/widget/details.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DetailsPage extends StatefulWidget {
  String stockName;
  String resolution;
  DetailsPage({required this.stockName, required this.resolution});
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  List<Candle> candles = [];
  List<double> points = [];
  double volume = 0;
  double currentPrice = 0;
  double currentHigh = 0;
  double currentLow = double.maxFinite;
  double currentOpen = 0;
  double previousClose = 0;
  bool isDown = false;
  // String resolution = "1";
  late int lastUpdated;
  Future<List<Candle>> getdata(String res) async {
    int a = DateTime.now().millisecondsSinceEpoch;
    int b = DateTime.now()
        .subtract(Duration(hours: 8 * resolutionMap[res]!))
        .millisecondsSinceEpoch;
    a = a ~/ 1000;
    b = b ~/ 1000;
    lastUpdated = a;
    var response = await http.get(Uri.parse(
        "https://finnhub.io/api/v1/stock/candle?symbol=${widget.stockName}&resolution=$res&from=$b&to=$a&token=c6av1iaad3ieq36s0q9g"));
    debugPrint(
        "https://finnhub.io/api/v1/stock/candle?symbol=${widget.stockName}&resolution=$res&from=$b&to=$a&token=c6av1iaad3ieq36s0q9g");
    var data = json.decode(response.body);
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

  bool addtocandle(var a) {
    var data = json.decode(a);
    var last1 =
        data["data"] != null ? data["data"][data["data"].length - 1] : "exit";
    if (last1 == "exit") {
      return false;
    }
    currentPrice = data["data"].last["p"].toDouble();
    if ((data["data"].last["t"] / 1000).toDouble() - lastUpdated.toDouble() <=
        60 * resolutionMap[widget.resolution]!) {
      points.add(data["data"].last["p"].toDouble());

      volume += data["data"].last["v"].toDouble();

      double high = data["data"].last["p"].toDouble() > candles[0].high
          ? data["data"].last["p"].toDouble()
          : candles[0].high;

      double low = data["data"].last["p"].toDouble() < candles[0].low
          ? data["data"].last["p"].toDouble()
          : candles[0].low;

      isDown = currentPrice > candles[0].open ? false : true;

      currentHigh = currentHigh > high ? currentHigh : high;

      currentLow = currentLow < low ? currentLow : low;

      currentOpen = candles[0].open;

      previousClose = candles[1].close;

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
      points.sort();
      double high = points.last.toDouble();
      double low = points.first.toDouble();

      Candle candle = Candle(
          close: points.last,
          open: points.first,
          date: DateTime.fromMillisecondsSinceEpoch(data["data"].last["t"]),
          high: high,
          low: low,
          volume: volume);

      // Adding new candle as per the resolution
      candles.insert(0, candle);
      //Resetting the volume and points for next set of iterations
      points.clear();
      volume = 0;
      lastUpdated = (data["data"].last["t"] / 1000).toInt();
      return true;
    }
  }

  void _addtochannel() {
    channel.sink.add('{"type": "subscribe", "symbol": "${widget.stockName}"}');
  }

  @override
  void initState() {
    super.initState();
  }

  void _closeschannel() {
    channel.sink.close();
  }

  void changeinterval(String value) {
    print("Changing the resolution $value");
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => DetailsPage(
                  stockName: widget.stockName,
                  resolution: value,
                )));
  }

  var channel;

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    channel = WebSocketChannel.connect(
      Uri.parse('wss://ws.finnhub.io?token=c6av1iaad3ieq36s0q9g'),
    );
    _addtochannel();
    debugPrint("The widget resolution is ${widget.resolution}");
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.stockName.split(":")[1]),
      ),
      body: FutureBuilder(
          future: getdata(widget.resolution),
          builder:
              (BuildContext context, AsyncSnapshot<List<Candle>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              return StreamBuilder(
                  stream: channel.stream,
                  builder: (context, snapshot1) {
                    // print('${data}')
                    snapshot1.hasData
                        ? addtocandle(snapshot1.data)
                        : debugPrint("null");

                    // print(.length);
                    if (snapshot1.hasData) {
                      if (addtocandle(snapshot1.data)) {
                        // print(candles[0]);
                        // print(resolutionMap3[widget.resolution]!);
                        return Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1.0,
                              child: Candlesticks(
                                onIntervalChange: (String value) async {
                                  print(value);
                                  changeinterval(resolutionMap2[value]!);
                                },
                                candles: candles,
                                interval: resolutionMap3[widget.resolution]!,
                                intervals: const [
                                  "1m",
                                  "5m",
                                  "15m",
                                  "30m",
                                  "1h",
                                  "1w",
                                  "1M",
                                  "1d"
                                ],
                              ),
                            ),
                            const Divider(
                              thickness: 2,
                            ),
                            PriceDetail(
                              isDown: isDown,
                              currentPrice: currentPrice,
                              currentHigh: currentHigh,
                              currentLow: currentLow,
                              currentOpen: currentOpen,
                              previousClose: previousClose,
                            )
                          ],
                        );
                      } else {
                        return AspectRatio(
                          aspectRatio: 1.2,
                          child: Candlesticks(
                            onIntervalChange: (String value) async {
                              print("the value is $value");
                            },
                            candles: snapshot.data!,
                            interval: widget.resolution,
                          ),
                        );
                      }
                    }
                    return const Center(child: CircularProgressIndicator());
                  });
            } else {
              debugPrint("Did not get data from the API");
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                    stockName: widget.stockName,
                                    resolution: widget.resolution,
                                  )),
                        );
                      },
                      child: const Icon(Icons.replay_outlined),
                    ),
                    const Text("An Error occured while calling the API"),
                  ],
                ),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _closeschannel,
        child: const Icon(Icons.close),
      ),
    );
  }
}

class PriceDetail extends StatelessWidget {
  const PriceDetail({
    Key? key,
    required this.isDown,
    required this.currentPrice,
    required this.previousClose,
    required this.currentHigh,
    required this.currentLow,
    required this.currentOpen,
  }) : super(key: key);

  final bool isDown;
  final double currentPrice;
  final double previousClose;
  final double currentHigh;
  final double currentLow;
  final double currentOpen;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            PriceDetailWidget(isDown: isDown, currentPrice: currentPrice),
            CloseDetailWidget(isDown: isDown, previousClose: previousClose),
          ],
        ),
        Row(
          children: [
            HighDetailWidget(isDown: isDown, currentHigh: currentHigh),
            LowDetailWidget(isDown: isDown, currentLow: currentLow),
            OpenDetailWidget(isDown: isDown, currentOpen: currentOpen),
          ],
        ),
      ],
    );
  }
}
