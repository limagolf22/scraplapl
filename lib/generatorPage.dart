import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scraplapl/FuelPage.dart';
import 'package:scraplapl/PerfoPage.dart';

class generatorPage extends StatelessWidget {
  const generatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Route'),
        actions: <Widget>[
          IconButton(
            color: const Color.fromARGB(255, 255, 255, 255),
            icon: const Icon(Icons.oil_barrel_rounded),
            tooltip: 'go to oil page',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FuelPage()),
              );
            },
          ),
          IconButton(
            color: const Color.fromARGB(255, 255, 255, 255),
            icon: const Icon(Icons.flight_takeoff),
            tooltip: 'go to oil page',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PerfoPage()),
              );
            },
          )
        ],
      ),
      body: TextButton(
        child: Text("generate PDF"),
        onPressed: () {},
      ),
    );
  }
}
