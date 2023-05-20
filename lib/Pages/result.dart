import 'package:flutter/material.dart';
import 'dart:io';

class ResultScreen extends StatelessWidget {
  const ResultScreen({Key? key, required this.file, required this.response})
      : super(key: key);
  final File file;
  final String response;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Predicted"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              child: Image.file(file),
            ),
            const SizedBox(height: 60),
            Text("Response: $response"),
          ],
        ),
      ),
    );
  }
}
