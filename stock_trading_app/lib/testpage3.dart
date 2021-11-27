import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:stock_trading_app/constants.dart/resolution.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TestPage3 extends StatefulWidget {
  String stockName;
  TestPage3({required this.stockName});
  @override
  _TestPage3State createState() => _TestPage3State();
}

class _TestPage3State extends State<TestPage3> {
  List<Candle> candles = [];
  List<double> points = [];
  double volume = 0;
  double currentPrice = 0;
  double currentHigh = 0;
  double currentLow = double.maxFinite;
  double currentOpen = 0;
  double previousClose = 0;
  bool isDown = false;
  String resolution = "1";
  late int last_updated;
  Future<List<Candle>> getdata(String res) async {
    print("Getting initial Data $res");
    int a = DateTime.now().millisecondsSinceEpoch;
    int b = DateTime.now()
        .subtract(Duration(hours: 8 * resolutionMap[res]!))
        .millisecondsSinceEpoch;
    a = a ~/ 1000;
    b = b ~/ 1000;
    last_updated = a;
    // print(b);
    // print(a);
    // print(resolution);
    var response = await http.get(Uri.parse(
        "https://finnhub.io/api/v1/stock/candle?symbol=${widget.stockName}&resolution=$res&from=$b&to=$a&token=c6av1iaad3ieq36s0q9g"));
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
    print((data["data"].last["t"] / 1000) - last_updated.toDouble());
    currentPrice = data["data"].last["p"].toDouble();
    if ((data["data"].last["t"] / 1000).toDouble() - last_updated.toDouble() <=
        60 * resolutionMap[resolution]!) {
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
      double close = points.last.toDouble();
      double open = points.first.toDouble();
      points.sort();
      double high = points.last.toDouble();
      double low = points.first.toDouble();
      debugPrint("Added a candle");
      debugPrint(DateTime.fromMillisecondsSinceEpoch(data["data"].last["t"])
          .toString());

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
      last_updated = (data["data"].last["t"] / 1000).toInt();
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
    setState(() {
      _closeschannel();
      print(resolutionMap2[value]!);
      this.resolution = resolutionMap2[value]!;
    });
  }

  var channel;

  @override
  void dispose() {
    channel.sink.close();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    channel = WebSocketChannel.connect(
      Uri.parse('wss://ws.finnhub.io?token=c6av1iaad3ieq36s0q9g'),
    );
    print("build called");
    print(resolution);
    print(resolutionMap3[resolution]!);
    _addtochannel();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.stockName.split(":")[1]),
      ),
      body: FutureBuilder(
          future: getdata(resolution),
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
                        : print("null");

                    // print(.length);
                    if (snapshot1.hasData) {
                      if (addtocandle(snapshot1.data)) {
                        // print(candles[0]);
                        print(resolutionMap3[resolution]!);
                        return Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1.2,
                              child: Candlesticks(
                                onIntervalChange: (String value) async {
                                  print(value);
                                  changeinterval(value);
                                },
                                candles: candles,
                                interval: resolutionMap3[resolution]!,
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
                            priceDetail(
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
            } else {
              debugPrint("Did not get data from the API");
              return const Center(
                child: Text("An Error occured while calling the API"),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _closeschannel,
        child: Icon(Icons.close),
      ),
    );
  }
}

class priceDetail extends StatelessWidget {
  const priceDetail({
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
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDown ? Colors.red : Colors.green,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[900],
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 8.0, 0, 0),
                            child: Text(
                              "PRICE",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8.0, 2, 8, 8),
                                child: Text(
                                  currentPrice.toString(),
                                  // overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDown ? Colors.red : Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDown ? Colors.red : Colors.green,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[900],
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 8.0, 0, 0),
                            child: Text(
                              "CLOSE",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8.0, 2, 8, 8),
                                child: Text(
                                  previousClose.toString(),
                                  // overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDown ? Colors.red : Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDown ? Colors.red : Colors.green,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[900],
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 8.0, 0, 0),
                            child: Text(
                              "HIGH",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8.0, 2, 8, 8),
                                child: Text(
                                  currentHigh.toString(),
                                  // overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDown ? Colors.red : Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDown ? Colors.red : Colors.green,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[900],
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 8.0, 0, 0),
                            child: Text(
                              "LOW",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8.0, 2, 8, 8),
                                child: Text(
                                  currentLow.toString(),
                                  // overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDown ? Colors.red : Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDown ? Colors.red : Colors.green,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[900],
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 8.0, 0, 0),
                            child: Text(
                              "OPEN",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8.0, 2, 8, 8),
                                child: Text(
                                  currentOpen.toString(),
                                  // overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDown ? Colors.red : Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
