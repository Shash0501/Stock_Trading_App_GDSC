import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stock_trading_app/constants.dart/channels.dart';
import 'package:stock_trading_app/constants.dart/common_symbol.dart';
import 'package:stock_trading_app/constants.dart/style.dart';
import 'package:stock_trading_app/pages/details_page.dart';
import 'package:stock_trading_app/pages/favourite_page.dart';
import 'package:stock_trading_app/model/favourite_crypto.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textFieldController = TextEditingController();
  String searchText = "";
  Future<List<dynamic>>? _searchedstockSymbols;

  //? This function searches the cryptosymbols on user's input
  Future<List<dynamic>> fetchSearchedStocks(String searchText) async {
    var searchedcrypto = [];
    try {
      var response = await http.get(Uri.parse(
          "https://finnhub.io/api/v1/search?q=$searchText&token=c6av1iaad3ieq36s0q9g"));

      var data = json.decode(response.body);
      searchedcrypto = data["result"];
    } catch (e) {
      debugPrint(e.toString());
    }
    return searchedcrypto;
  }

  @override
  Widget build(BuildContext context) {
    var box = Hive.box<Favourite>("favourite");

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("NITK STOCKS"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.star,
              color: Colors.yellow,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavouritePage(),
                ),
              );
            },
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
                itemCount: stockSymbols.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                    symbol: stockSymbols[index].symbol,
                                    description:
                                        stockSymbols[index].description,
                                    displaySymbol:
                                        stockSymbols[index].displaySymbol,
                                  )));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 100,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              stockSymbols[index].displaySymbol,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        decoration: bhp1,
                      ),
                    ),
                  );
                }),
          ),
          const Divider(
            thickness: 2,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 10.0),
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
                          ? 'Search stocks'
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
                                  _searchedstockSymbols = null;
                                });
                              },
                            ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onChanged: (text) {
                      setState(() {
                        searchText = text;
                        _searchedstockSymbols = fetchSearchedStocks(searchText);
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          _searchedstockSymbols != null
              ? result(_searchedstockSymbols!)
              : favourites(),
        ],
      ),
    );
  }

  Widget favourites() {
    var box = Hive.box<Favourite>("favourite");
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 25.0),
      child: Container(
        child: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (BuildContext context, dynamic box, _) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: box.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetailsPage(
                                  symbol: box.getAt(index).symbol,
                                  description: box.getAt(index).description,
                                  displaySymbol: box.getAt(index).displaySymbol,
                                )));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      tileColor: Colors.grey[600],
                      title: Text(
                        box.getAt(index).symbol,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(box.getAt(index).description,
                          style: const TextStyle(color: Colors.black)),
                      trailing: box.containsKey(box.getAt(index).symbol)
                          ? IconButton(
                              onPressed: () {
                                box.deleteAt(index);
                              },
                              icon: const Icon(
                                Icons.star,
                                color: Color(0xFFF2C611),
                              ))
                          : null,
                    ),
                  ),
                );
              },
            );
            ;
          },
        ),
      ),
    );
  }

  Widget result(Future<List<dynamic>> cryptos) {
    var box = Hive.box<Favourite>("favourite");

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
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                    symbol: snapshot.data![index]['symbol'],
                                    description: snapshot.data![index]
                                        ['description'],
                                    displaySymbol: snapshot.data![index]
                                        ['displaySymbol'],
                                  )));
                    },
                    child: ListTile(
                      title: Text(snapshot.data![index]['symbol']),
                      subtitle: Text(snapshot.data![index]['description']),
                      trailing: box.containsKey(snapshot.data![index]['symbol'])
                          ? const Icon(
                              Icons.star,
                              color: Colors.yellow,
                            )
                          : null,
                    ),
                  );
                },
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const Center(
            child: Padding(
          padding: EdgeInsets.fromLTRB(8, 30, 8, 8),
          child: CircularProgressIndicator(
            color: Colors.cyan,
          ),
        ));
      },
    );
  }
}
