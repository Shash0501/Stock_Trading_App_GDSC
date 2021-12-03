import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

BoxDecoration bhp1 = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    gradient: RadialGradient(
      colors: [
        Colors.amber[300]!,
        Colors.amber[400]!,
        Colors.amber[600]!,
        Colors.amber[700]!,
      ],
      stops: const [0.4, 0.6, 0.8, 1],
    ));
