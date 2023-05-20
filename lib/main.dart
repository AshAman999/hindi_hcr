import 'package:flutter/material.dart';
import 'package:hindi_hcr/Pages/fileSelect.dart';
import 'package:hindi_hcr/Pages/handwriting.dart';

import 'Pages/picture_click.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hindi HWCR'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: const Center(
                child: Text('Banner'),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PictureClick()),
                )
              },
              child: Container(
                color: Colors.red,
                child: const Center(
                  child: Text('Camera'),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FileSelect()),
                )
              },
              child: Container(
                child: const Center(
                  child: Text('File'),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HandWriting()),
                )
              },
              child: Container(
                child: const Center(
                  child: Text('HandWriting'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
