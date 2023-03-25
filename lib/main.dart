import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quran App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPage = 1;
  dynamic ayatList = [];
  PageController pageController = PageController(initialPage: 1);

  Future<void> readJson() async {
    final String response =
    await rootBundle.loadString('assets/hafs_smart_v8.json');
    ayatList = jsonDecode(response) as List;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 1);
    readJson();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            width: double.infinity,
            height: 40,
            color: Colors.white,
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'اكتب رقم الصفحة',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) {
                pageChanged(int.parse(value));
              },
            ),
          ),
        ),
        body: SafeArea(
          minimum: EdgeInsets.all(15),
          child: PageView.builder(
            itemCount: 114,
            controller: pageController,
            onPageChanged: (page) {
              setState(() {
                pageChanged(page);
                print('currentPage: $page');
                readJson();
                setState(() {});
              });
            },
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(15),
                child: Expanded(
                  child: RichText(
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                        text: '',
                        recognizer: DoubleTapGestureRecognizer()
                          ..onDoubleTap = () {
                            setState(() {});
                          },
                        style: const TextStyle(
                          fontFamily: 'Kitab',
                          color: Colors.black,
                          fontSize: 24,
                          textBaseline: TextBaseline.alphabetic,
                        ),
                        children: [
                          for (var item in ayatList) ...{
                            if (currentPage == item['page']) ...{
                              TextSpan(
                                text: '${item['aya_text_emlaey']}',
                              ),
                              WidgetSpan(
                                baseline: TextBaseline.alphabetic,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 8),
                                  decoration: BoxDecoration(
                                    image: const DecorationImage(
                                      opacity: 0.5,
                                      image: AssetImage(
                                        'images/end.png',
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('${item['aya_no']}'),
                                ),
                              ),
                            },
                          },
                        ]),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void pageChanged(int index) {
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 3000),
        curve: Curves.elasticInOut);

    // or this to jump to it without animating
    pageController.jumpToPage(index);
    setState(() {
      currentPage = index;
    });
  }
}
