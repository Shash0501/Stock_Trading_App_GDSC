import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_trading_app/homepage.dart';
import 'package:stock_trading_app/testpage2.dart';
import 'package:stock_trading_app/testpage3.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

import 'bloc/stock_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StockBloc(),
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: TestPage3()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    channel.sink.add('{"type": "subscribe", "symbol": "BINANCE:BTCUSDT"}');
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    channel.sink.close();
    setState(() {
      _counter++;
    });
  }

  void printdata(var a) {
    var data = json.decode(a);
    for (var item in data["data"]) {
      print(item["p"]);
    }
  }

  final channel = WebSocketChannel.connect(
    Uri.parse('wss://ws.finnhub.io?token=c6av1iaad3ieq36s0q9g'),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          print(
              "\n================================================================\n");

          snapshot.hasData ? printdata(snapshot.data) : print("null");
          print(
              "\n================================================================\n");
          return Text(snapshot.hasData ? '${snapshot.data}' : '');
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            heroTag: 'decrement',
            onPressed: _decrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
