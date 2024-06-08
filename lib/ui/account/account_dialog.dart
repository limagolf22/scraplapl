import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:scraplapl/main.dart';
import 'package:scraplapl/tools.dart';

void openLoginDialog(BuildContext context) {
  Logger loggerDialog = Logger();
  String internalLogin = personalFolder;
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
                    validator: validateName,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      icon: Icon(Icons.account_box),
                    ),
                    onChanged: (value) {
                      internalLogin = value;
                    }),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text("submit"),
            onPressed: () {
              personalFolder = internalLogin;
              loggerDialog.i("internal folder changed: $personalFolder");
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ],
      );
    },
  );
}

String? validateName(String? name) {
  return (name != null && !AppUtil.isCorrectPersonalFolder(name))
      ? "wrong folder name"
      : null;
}
