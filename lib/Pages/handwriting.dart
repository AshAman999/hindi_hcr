// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:hindi_hcr/Constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hindi_hcr/Pages/result.dart';
import 'package:whiteboard/whiteboard.dart';
import 'package:path_provider/path_provider.dart';

class HandWriting extends StatefulWidget {
  const HandWriting({super.key, required this.whiteBoardController});

  final WhiteBoardController whiteBoardController;

  @override
  State<HandWriting> createState() => _HandWritingState();
}

class _HandWritingState extends State<HandWriting> {
  String predicted_handwriting = "";

  Future<void> fetchResponse(File file) async {
    // Fetch data from internet
    var uri = '$serverUrl/upload_image/';

    var request = http.MultipartRequest('POST', Uri.parse(uri));

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();

    var responded = await http.Response.fromStream(response);

    final responseData = json.decode(responded.body);
    setState(() {
      predicted_handwriting = responseData['predicted_handwriting'];
    });
  }

  String generateRandomFileName() {
    // A list of possible characters to use in the name
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    // A random number generator
    final rng = Random();
    // A variable to store the name
    String name = '';
    // A loop to generate a name of length 8
    for (int i = 0; i < 8; i++) {
      // Append a random character from the list
      name += chars[rng.nextInt(chars.length)];
    }
    // Return the name
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Handwriting'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    widget.whiteBoardController.undo();
                  },
                  child: const Text('Undo'),
                ),
                TextButton(
                  onPressed: () {
                    widget.whiteBoardController.redo();
                  },
                  child: const Text('Redo'),
                ),
                TextButton(
                  onPressed: () async {
                    widget.whiteBoardController.clear();
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              width: 300,
              child: WhiteBoard(
                backgroundColor: const Color.fromARGB(255, 224, 242, 249),
                onConvertImage: (value) async {
                  if (kDebugMode) {
                    print(value);
                  }
                  final Directory dir = await getTemporaryDirectory();
                  final file =
                      await File('${dir.path}/${generateRandomFileName()}.jpg')
                          .create(recursive: true);
                  file.writeAsBytesSync(value, mode: FileMode.writeOnly);

                  // Fetch Request
                  await fetchResponse(file);

                  // ignore: use_build_context_synchronously
                  if (!context.mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(
                        file: file,
                        response: predicted_handwriting,
                      ),
                    ),
                  );
                  // save this image to your local storage as jpeg file
                },
                controller: widget.whiteBoardController,
              ),
            ),
            const SizedBox(height: 20),
            CupertinoButton(
              color: Colors.blueAccent,
              onPressed: () {
                widget.whiteBoardController.convertToImage(
                  format: ImageByteFormat.png,
                );
              },
              child: const Text('Process'),
            ),
          ],
        ),
      ),
    );
  }
}
