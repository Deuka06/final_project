import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OtherPage extends StatefulWidget {
  const OtherPage({Key? key}) : super(key: key);

  @override
  _OtherPageState createState() => _OtherPageState();
}

class _OtherPageState extends State<OtherPage> {
  String imageUrl = 'Нажмите кнопку, чтобы загрузить изображение кота';

  Future<void> fetchCatImage() async {
    final response =
        await http.get(Uri.parse('https://api.thecatapi.com/v1/images/search'));

    if (response.statusCode == 200) {
      setState(() {
        imageUrl = json.decode(response.body)[0]['url'];
      });
    } else {
      setState(() {
        imageUrl = 'Ошибка при загрузке изображения кота';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Other Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              imageUrl,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchCatImage,
              child: Text('Загрузить изображение кота'),
            ),
          ],
        ),
      ),
    );
  }
}
