import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_trading_app/constants.dart/common_crypto.dart';

import 'bloc/stock_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NITK CRYPTO"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: crypto_symbols.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            crypto_symbols[index].description.split(" ")[1],
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.amber),
                    ),
                  );
                }),
          ),
          const Divider(
            thickness: 2,
          ),
          BlocBuilder<StockBloc, StockState>(
            builder: (context, state) {
              if (state is Loading) {
                return CircularProgressIndicator();
              } else if (state is StockInitial) {
                return Text("asd");
              } else if (state is StockSymbolsLoaded) {
                return Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: state.stocks.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(color: Colors.grey),
                              child: Text(state.stocks[index].description
                                  .split(" ")[1]),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return Container();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BlocProvider.of<StockBloc>(context).add(getstocksymbolsEvent());
        },
      ),
    );
  }
}
