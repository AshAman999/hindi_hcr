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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Image.file(file), Text("Response: $response")],
      ),
    );
  }
}
