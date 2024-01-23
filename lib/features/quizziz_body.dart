import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:url_launcher/url_launcher.dart';

import 'other_page.dart';
import 'quizziz_screen.dart';

class QuizzizBody extends StatefulWidget {
  const QuizzizBody({Key? key}) : super(key: key);

  @override
  State<QuizzizBody> createState() => _QuizzizBodyState();
}

class _QuizzizBodyState extends State<QuizzizBody> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _photoLinkController = TextEditingController();
  final TextEditingController _webLinkController = TextEditingController();

  List<Map<String, dynamic>> _items = [];

  void _refreshItems() {
    final data = _lessonsBox.keys.map((key) {
      final item = _lessonsBox.get(key);
      return {
        "key": key,
        "title": item['title'],
        "photo_link": item['photo_link'],
        "web_link": item['web_link']
      };
    }).toList();

    setState(() {
      _items = data.reversed.toList();
      print(_items.length);
    });
  }

  final _lessonsBox = Hive.box('lessons_box');

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _lessonsBox.add(newItem);
    _refreshItems();
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _lessonsBox.put(itemKey, item);
    _refreshItems();
  }

  Future<void> _deleteItem(int itemKey) async {
    await _lessonsBox.delete(itemKey);
    _refreshItems();

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An item has been deleted')));
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemKey);
      _titleController.text = existingItem['title'];
      _photoLinkController.text = existingItem['photo_link'];
      _webLinkController.text = existingItem['web_link'];
    }
    showModalBottomSheet(
      context: ctx,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 15,
            left: 15,
            right: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _photoLinkController,
              decoration: const InputDecoration(hintText: "Photo link"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _webLinkController,
              decoration: const InputDecoration(hintText: "Web link"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (itemKey == null) {
                  _createItem({
                    "title": _titleController.text,
                    "photo_link": _photoLinkController.text,
                    "web_link": _webLinkController.text
                  });
                }

                if (itemKey != null) {
                  _updateItem(itemKey, {
                    'title': _titleController.text.trim(),
                    'photo_link': _photoLinkController.text.trim(),
                    'web_link': _webLinkController.text.trim()
                  });
                }

                _titleController.text = '';
                _photoLinkController.text = '';
                _webLinkController.text = '';

                Navigator.of(context).pop();
              },
              child: Text(itemKey == null ? 'Create new' : 'Update'),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _quizzizView(context);
  }

  Widget _quizzizView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  _quizList(context),
                  SizedBox(height: 16),
                  _navigateToOtherPageButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// Widget _quizList(BuildContext context) {
//   return SingleChildScrollView(
//     scrollDirection: Axis.vertical,
//     child: Column(
//       children: <Widget>[
//         _listItem(
//           Image.asset('assets/images/android.jpeg'),
//           'Андроид сабағы',
//           context,
//         ),
//         SizedBox(
//           height: 16,
//         ),
//         _listItem(
//           Image.asset('assets/images/flutter.jpeg'),
//           'Dart & Flutter сабағы',
//           context,
//         ),
//         SizedBox(
//           height: 16,
//         ),
//         _listItem(
//           Image.asset('assets/images/blender.jpeg'),
//           'Full-stack веб сабағы',
//           context,
//         ),
//         SizedBox(
//           height: 16,
//         ),
//         _listItem(
//           Image.asset('assets/images/kotlin.jpeg'),
//           'Full-stack веб сабағы',
//           context,
//         ),
//         SizedBox(
//           height: 16,
//         ),
//         _listItem(
//           Image.asset('assets/images/java.jpeg'),
//           'Full-stack веб сабағы',
//           context,
//         ),
//         SizedBox(
//           height: 16,
//         ),
//         _listItem(
//           Image.asset('assets/images/full_stack.jpeg'),
//           'Full-stack веб сабағы',
//           context,
//         ),
//       ],
//     ),
//   );
// }

  @override
  Widget _quizList(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
          ),
          onPressed: () => _showForm(context, null),
          child: const Icon(Icons.add),
        ),
        SizedBox(height: 35),
        Container(
          height: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final currentItem = _items[index];
              return Card(
                child: _listItem(
                  context: context,
                  index: index,
                  urlPhoto: currentItem['photo_link'],
                  urlLink: currentItem['web_link'],
                  title: currentItem['title'],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _listItem({
    required BuildContext context,
    required int index,
    required String urlPhoto,
    required String urlLink,
    required String title,
  }) {
    final currentItem = _items[index];
    return Container(
      width: 70,
      height: 120,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8), // Image border
                child: SizedBox.fromSize(
                  size: const Size.fromRadius(90), // Image radius
                  child: Image.network(
                    urlPhoto,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 80, bottom: 200),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.black54,
                        ),
                        onPressed: () => _showForm(context, currentItem["key"]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 20,
                            color: Colors.black54,
                          ),
                          onPressed: () => _deleteItem(currentItem["key"]),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final url = Uri.parse(currentItem['web_link']);
                            if (!await launchUrl(url)) {
                              throw Exception('Could not launch $url');
                            }
                          },
                          child: Container(
                            child: Text(
                              title,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => QuizzizScreen()),
                            );
                          },
                          child: Text(
                            "Тестті тапсыру",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _navigateToOtherPageButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtherPage(),
          ),
        );
      },
      child: Text(
        "Перейти на другую страницу",
        style: TextStyle(color: Colors.white),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.red),
      ),
    );
  }
}
