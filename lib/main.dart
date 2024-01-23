import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:test1/features/quizziz_body.dart';

// void main() => runApp(MyApp());
void main() async {
  await Hive.initFlutter();
  await Hive.openBox('lessons_box');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Roboto'),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Quizziz',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          // leading: IconButton(
          //   icon: Icon(Icons.menu),
          //   onPressed: () {},
          // ),
          iconTheme: IconThemeData(color: Colors.black54, size: 26),
          // actions: <Widget>[
          //   IconButton(
          //     icon: Icon(Icons.search),
          //     onPressed: () {},
          //   )
          // ],
        ),
        body: QuizzizBody(),
      ),
    );
  }
}
