import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:whiteboard/whiteboard.dart';

class HandWriting extends StatefulWidget {
  const HandWriting({super.key});

  @override
  State<HandWriting> createState() => _HandWritingState();
}

class _HandWritingState extends State<HandWriting> {
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
                    child: const Text('Undo')),
                TextButton(
                    onPressed: () {
                      whiteBoardController.redo();
                    },
                    child: const Text('Redo')),
                TextButton(
                    onPressed: () async {
                      whiteBoardController.clear();
                    },
                    child: const Text('Clear')),
              ],
            ),
            SizedBox(
              height: 300,
              width: 300,
              child: WhiteBoard(
                onConvertImage: (value) {
                  if (kDebugMode) {
                    print(value);
                  }

                  // save this image to your local storage as jpeg file
                },
                controller: whiteBoardController,
              ),
            ),
            TextButton(
                onPressed: () {
                  whiteBoardController.convertToImage(
                      format: ImageByteFormat.png);
                },
                child: const Text('Capture')),
          ],
        ),
      ),
    );
  }
}
