import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_trading_app/constants.dart/channels.dart';
import 'package:stock_trading_app/constants.dart/common_crypto.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import 'bloc/stock_bloc.dart';
import 'model/crypto_symbol.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textFieldController = TextEditingController();
  String searchText = "";
  Future<List<dynamic>>? _searchedcryptoSymbols;
  Future<List<dynamic>> fetchSearchedCryptos(String searchText) async {
    var searchedcrypto = [];
    try {
      var response = await http.get(Uri.parse(
          "https://finnhub.io/api/v1/search?q=Binance$searchText&token=c6av1iaad3ieq36s0q9g"));
      var data = json.decode(response.body);
      searchedcrypto = data["result"];
    } catch (e) {
      print(e);
    }
    return searchedcrypto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NITK CRYPTO"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
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
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: RadialGradient(
                            colors: [
                              Colors.amber[300]!,
                              Colors.amber[400]!,
                              Colors.amber[600]!,
                              Colors.amber[700]!,
                            ],
                            stops: const [0.4, 0.6, 0.8, 1],
                          )),
                    ),
                  );
                }),
          ),
          const Divider(
            thickness: 2,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 29.0),
            child: Container(
              height: 60.0,
              child: Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 8, 8, 8),
                  child: TextField(
                    cursorWidth: 1,
                    cursorColor: Colors.cyan[800],
                    controller: _textFieldController,
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.white),
                      labelText: _textFieldController.text == null ||
                              _textFieldController.text == ''
                          ? 'Search cryptos'
                          : '',
                      suffixIcon: searchText == ""
                          ? const Icon(
                              Icons.search,
                              color: Colors.white,
                            )
                          : IconButton(
                              icon: const Icon(Icons.close),
                              color: Colors.white,
                              onPressed: () {
                                _textFieldController.clear();
                                setState(() {
                                  searchText = "";
                                  _searchedcryptoSymbols = [] as Future<List>?;
                                });
                              },
                            ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onChanged: (text) {
                      setState(() {
                        searchText = text;
                        _searchedcryptoSymbols =
                            fetchSearchedCryptos(searchText);
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          _searchedcryptoSymbols != null
              ? result(_searchedcryptoSymbols!)
              : Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BlocProvider.of<StockBloc>(context).add(getstocksymbolsEvent());
        },
      ),
    );
  }

  Widget result(Future<List<dynamic>> cryptos) {
    return FutureBuilder<List<dynamic>>(
      future: cryptos,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty && _textFieldController.text == '') {
          } else if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No results found"),
            );
          } else {
            return Expanded(
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(snapshot.data![index]['symbol']),
                    subtitle: Text(snapshot.data![index]['description']),
                  );
                },
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
