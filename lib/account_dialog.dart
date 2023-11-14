import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void open_login_dialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: true,
        title: const Text("Give your folder name"),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Name",
                    icon: Icon(Icons.account_box),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text("submit"),
            onPressed: () {
              // your code
            },
          ),
        ],
      );
    },
  );
}
