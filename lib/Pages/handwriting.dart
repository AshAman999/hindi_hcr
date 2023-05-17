import 'dart:io';
import 'dart:ui';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hindi_hcr/Pages/result.dart';
import 'package:whiteboard/whiteboard.dart';
import 'package:path_provider/path_provider.dart';

class HandWriting extends StatefulWidget {
  const HandWriting({super.key});

  @override
  State<HandWriting> createState() => _HandWritingState();
}

class _HandWritingState extends State<HandWriting> {
  String response = "";

  Future<void> fetchResponse(File file) async {
    // Fetch data from internet
    const uri = "https://9f51-202-142-81-154.ngrok-free.app/upload_image/";

    var request = http.MultipartRequest('POST', Uri.parse(uri));

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var resp = await request.send();

    setState(() {
      response = resp.reasonPhrase!;
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
    WhiteBoardController whiteBoardController = WhiteBoardController();
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
                    whiteBoardController.undo();
                  },
                  child: const Text('Undo'),
                ),
                TextButton(
                  onPressed: () {
                    whiteBoardController.redo();
                  },
                  child: const Text('Redo'),
                ),
                TextButton(
                  onPressed: () async {
                    whiteBoardController.clear();
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
            SizedBox(
              height: 300,
              width: 300,
              child: WhiteBoard(
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

                  if (!context.mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(
                        file: file,
                        response: response,
                      ),
                    ),
                  );
                  // save this image to your local storage as jpeg file
                },
                controller: whiteBoardController,
              ),
            ),
            TextButton(
              onPressed: () {
                whiteBoardController.convertToImage(
                  format: ImageByteFormat.png,
                );
              },
              child: const Text('Capture'),
            ),
          ],
        ),
      ),
    );
  }
}
