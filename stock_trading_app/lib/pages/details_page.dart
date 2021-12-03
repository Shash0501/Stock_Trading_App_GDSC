import 'dart:convert';

import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:stock_trading_app/constants.dart/resolution.dart';
import 'package:stock_trading_app/widget/details.dart';

import '../model/favourite_crypto.dart';

class DetailsPage extends StatefulWidget {
  final String symbol;
  final String description;
  final String displaySymbol;

  DetailsPage(
      {required this.symbol,
      required this.description,
      required this.displaySymbol});
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  String resolution = "1";
  var box = Hive.box<Favourite>("favourite");
  List<Candle> candles = [];
  List<double> points = [];
  double volume = 0;
  double currentPrice = 0;
  double currentHigh = 0;
  double currentLow = double.maxFinite;
  double currentOpen = 0;
  double previousClose = 0;
  bool isDown = false;
  double percentage = 0;
  // String resolution = "1";
  late int lastUpdated;
  Future<List<Candle>> getdata(String res) async {
    print("getting res $res");
    int a = DateTime.now().millisecondsSinceEpoch;
    int b = DateTime.now()
        .subtract(Duration(hours: 8 * resolutionMap[res]!))
        .millisecondsSinceEpoch;
    a = a ~/ 1000;
    b = b ~/ 1000;
    lastUpdated = a;
    var response = await http.get(Uri.parse(
        "https://finnhub.io/api/v1/stock/candle?symbol=${widget.symbol}&resolution=$res&from=$b&to=$a&token=c6av1iaad3ieq36s0q9g"));
    debugPrint(
        "https://finnhub.io/api/v1/stock/candle?symbol=${widget.symbol}&resolution=$res&from=$b&to=$a&token=c6av1iaad3ieq36s0q9g");
    var data = json.decode(response.body);
    candles = [];
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
      percentage = ((currentPrice - previousClose) / previousClose) * 100;
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
    channel.sink.add('{"type": "subscribe", "symbol": "${widget.symbol}"}');
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
      this.resolution = value;
    });
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
    String a = resolution;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.symbol.split(":")[1]),
        actions: [
          IconButton(
            icon: Icon(
              Icons.star,
              color:
                  box.containsKey(widget.symbol) ? Colors.yellow : Colors.grey,
            ),
            onPressed: () {
              if (box.containsKey(widget.symbol)) {
                setState(() {
                  box.delete(widget.symbol);
                });
              } else {
                setState(() {
                  box.put(
                      widget.symbol,
                      Favourite(
                          symbol: widget.symbol,
                          description: widget.description,
                          displaySymbol: widget.displaySymbol));
                  ScaffoldMessenger.of(context)
                      .showSnackBar(snackBarWidget(box, widget.symbol));
                });
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
          future: getdata(resolution),
          builder:
              (BuildContext context, AsyncSnapshot<List<Candle>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.cyan,
              ));
            } else if (snapshot.hasData) {
              print("building candles");

              return StreamBuilder(
                  stream: channel.stream,
                  builder: (context, snapshot1) {
                    snapshot1.hasData
                        ? addtocandle(snapshot1.data)
                        : debugPrint("null");

                    if (snapshot1.hasData) {
                      if (addtocandle(snapshot1.data)) {
                        debugPrint("got data ${resolutionMap3[resolution]!}");
                        return Column(
                          children: [
                            Row(
                              children: [
                                PriceDetailWidget(
                                    isDown: isDown, currentPrice: currentPrice),
                                HighDetailWidget(
                                    isDown: isDown, currentHigh: currentHigh),
                                LowDetailWidget(
                                    isDown: isDown, currentLow: currentLow),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey[600]!,
                                  width: 1,
                                ),
                              ),
                              child: AspectRatio(
                                aspectRatio: MediaQuery.of(context).size.width /
                                    (MediaQuery.of(context).size.height - 170),
                                child: Candlesticks(
                                    onIntervalChange: (String value) async {
                                      return changeinterval(
                                          resolutionMap2[value]!);
                                      // return Future<void>(null);
                                    },
                                    candles: candles,
                                    interval: resolutionMap3[a]!,
                                    intervals: resolutionList),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const CircularProgressIndicator(
                          color: Colors.cyan,
                        );
                      }
                    }
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.cyan,
                    ));
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
                                    symbol: widget.symbol,
                                    description: widget.description,
                                    displaySymbol: widget.displaySymbol,
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
    );
  }
}

SnackBar snackBarWidget(var box, String symbol) {
  return SnackBar(
    backgroundColor: Colors.grey,
    elevation: 2,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))),
    content: const Text("Added to favourites"),
    action: SnackBarAction(
      label: "Undo",
      onPressed: () {
        box.deleteAt(box.indexOf(symbol));
      },
    ),
  );
}

// class PriceDetail extends StatelessWidget {
//   const PriceDetail({
//     Key? key,
//     required this.isDown,
//     required this.currentPrice,
//     required this.previousClose,
//     required this.currentHigh,
//     required this.currentLow,
//     required this.currentOpen,
//   }) : super(key: key);

//   final bool isDown;
//   final double currentPrice;
//   final double previousClose;
//   final double currentHigh;
//   final double currentLow;
//   final double currentOpen;
//   @override
//   Widget build(BuildContext context) {
//     String percentage =
//         ((currentPrice - previousClose) / previousClose * 100).toString();

//     return Expanded(
//       child: Column(
//         // crossAxisAlignment: CrossAxisAlignment.start,
//         // mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Expanded(
//             // flex: 1,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     // mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       PriceDetailWidget(
//                           isDown: isDown, currentPrice: currentPrice),
//                       HighDetailWidget(
//                           isDown: isDown, currentHigh: currentHigh),
//                       LowDetailWidget(isDown: isDown, currentLow: currentLow),
//                     ],
//                   ),
//                 ),
//                 Card(
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         Text(
//                             "${percentage.substring(0, percentage.length % 4)} %",
//                             style: const TextStyle(fontSize: 20)),
//                         const SizedBox(
//                           width: 10,
//                         ),
//                         Icon(
//                           isDown ? Icons.arrow_downward : Icons.arrow_upward,
//                           size: 30,
//                           color: isDown ? Colors.red : Colors.green,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Row(
//             children: [
//               OpenDetailWidget(isDown: isDown, currentOpen: currentOpen),
//               CloseDetailWidget(isDown: isDown, previousClose: previousClose),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
