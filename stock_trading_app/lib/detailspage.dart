import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/stock_bloc.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StockBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Text"),
        ),
        body: BlocBuilder<StockBloc, StockState>(
          builder: (context, state) {
            if (state is StockInitial) {
              // BlocProvider.of<StockBloc>(context).add();
              return CircularProgressIndicator();
            }

            return Container();
          },
        ),
      ),
    );
  }
}
