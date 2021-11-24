import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        title: Text("SAD"),
      ),
      body: BlocBuilder<StockBloc, StockState>(
        builder: (context, state) {
          if (state is Loading) {
            return CircularProgressIndicator();
          } else if (state is StockInitial) {
            return Text("asd");
          } else if (state is StockSymbolsLoaded) {
            return ListView.builder(
              itemCount: state.stocks.length,
              itemBuilder: (BuildContext context, int index) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(color: Colors.grey),
                        child: Text(state.stocks[index].description),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BlocProvider.of<StockBloc>(context).add(getstocksymbolsEvent());
        },
      ),
    );
  }
}
