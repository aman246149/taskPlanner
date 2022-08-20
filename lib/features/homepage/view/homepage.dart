import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskplanner/providers/timerprovider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  TextEditingController controller = TextEditingController();
  ScrollController scrollcontroller = ScrollController();


/// initstate for getting our task messages whenver our app open
  @override
  void initState() {
    Provider.of<TimerProvider>(context, listen: false).getMessages();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

///if we closed our app our state should be save to local db
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      final provider = Provider.of<TimerProvider>(context, listen: false);
      provider.setMessages(provider.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("TaskPlanner"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          // color: Colors.deepPurpleAccent,
          width: size > 700 ? size / 2 : double.infinity,
          alignment: Alignment.center,
          child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Consumer<TimerProvider>(
                builder: (context, value, child) {
                  if (value.data.isEmpty) {
                    return const Center(
                      child: Text("You dont have any task ,please create task"),
                    );
                  }
                  return ListView.builder(
                    controller: scrollcontroller,
                    itemCount: value.data.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: GestureDetector(
                          onTap: () {
                            value.startTimer(index);
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10.0),
                            child: Card(
                              elevation: 5,
                              child: ListTile(
                                title: Text(value.data[index]["task"]),
                                trailing: Text(value.data[index]["timer"] == 0
                                    ? ""
                                    : value.data[index]["timer"].toString()),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              )),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.transparent,
          height: kToolbarHeight,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: size < 700
              ? const EdgeInsets.only(left: 16, right: 8)
              : const EdgeInsets.only(left: 200, right: 200),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'enter your task here',
                      // border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (controller.text.isEmpty) {
                    controller.text = "field cannot be empty";
                  } else {
                    Provider.of<TimerProvider>(context, listen: false)
                        .addDataInList(controller.text);
                    controller.text = "";
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
