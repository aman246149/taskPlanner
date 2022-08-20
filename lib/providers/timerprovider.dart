import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerProvider extends ChangeNotifier {
  List<Map<String, dynamic>> data = [];

  ///store data in db
  Future setMessages(List<Map> messages) async {
    final _preferences = await SharedPreferences.getInstance();

    List<String> messagesString = [];
    messages.forEach((element) {
      element["isWorking"] = false;
      messagesString.add(json.encode(element));
    });
    await _preferences.setStringList("mytimersList", messagesString);
  }

  ///get data from db
  Future<List<Map>> getMessages() async {
    final _preferences = await SharedPreferences.getInstance();
    List<String> messagesString =
        _preferences.getStringList("mytimersList") ?? [];
    List<Map<String, dynamic>> messages = [];
    if (messagesString.isNotEmpty) {
      messagesString.forEach((element) {
        messages.add(json.decode(element));
      });
    }
    data = messages;
    print(data.toString());
    notifyListeners();
    return Future.value(messages);
  }

  ///start stop timer
  void startTimer(int index) {
    int count = data[index]["timer"];
    if (data[index]["isWorking"] == false) {
      data[index]["isWorking"] = true;
    } else {
      data[index]["isWorking"] = false;
    }

    var timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        count++;
        data[index]["timer"] = count;
        notifyListeners();

        if (data[index]["isWorking"] == false) {
          print(data.toString());
          timer.cancel();
          setMessages(data);
        }
      },
    );

    notifyListeners();
  }

  /// add new task in listview
  void addDataInList(String task) {
    data.add(
      {"task": task, "timer": 0, "isWorking": false},
    );
    notifyListeners();
  }
}
