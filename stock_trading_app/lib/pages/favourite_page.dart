import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'details_page.dart';
import '../model/favourite_crypto.dart';

class FavouritePage extends StatelessWidget {
  const FavouritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var box = Hive.box<Favourite>("favourite");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite'),
      ),
      body: Container(
        child: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (BuildContext context, dynamic box, _) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: box.length,
              itemBuilder: (BuildContext context, int index) {
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                    symbol: box.getAt(index).symbol,
                                    description: box.getAt(index).description,
                                    displaySymbol:
                                        box.getAt(index).displaySymbol,
                                  )));
                    },
                    child: ListTile(
                      title: Text(box.getAt(index).symbol),
                      subtitle: Text(box.getAt(index).description),
                      trailing: box.containsKey(box.getAt(index).symbol)
                          ? IconButton(
                              onPressed: () {
                                box.deleteAt(index);
                              },
                              icon: const Icon(
                                Icons.star,
                                color: Colors.yellow,
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
}
