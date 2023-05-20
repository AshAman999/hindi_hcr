// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:hindi_hcr/Constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hindi_hcr/Pages/result.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
  bool loading = false;
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
      body: loading
          ? Center(
              child: LoadingAnimationWidget.prograssiveDots(
                color: Colors.blue,
                size: 100,
              ),
            )
          : Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('Assets/hindi_bg.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  width: double.infinity,
                  height: double.infinity,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                    child: Container(
                        // color: Colors.white.withOpacity(0.1),
                        ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GFButton(
                            shape: GFButtonShape.pills,
                            icon: const Icon(
                              Icons.undo,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              widget.whiteBoardController.undo();
                            },
                            child: const Text('Undo'),
                          ),
                          GFButton(
                            shape: GFButtonShape.pills,
                            icon: const Icon(
                              Icons.redo,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              widget.whiteBoardController.redo();
                            },
                            child: const Text('Redo'),
                          ),
                          GFButton(
                            shape: GFButtonShape.pills,
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              widget.whiteBoardController.clear();
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: WhiteBoard(
                          // backgroundColor: const Color.fromARGB(255, 224, 242, 249),
                          onConvertImage: (value) async {
                            if (kDebugMode) {
                              print(value);
                            }
                            setState(() {
                              loading = true;
                            });
                            final Directory dir = await getTemporaryDirectory();
                            final file = await File(
                                    '${dir.path}/${generateRandomFileName()}.jpg')
                                .create(recursive: true);
                            file.writeAsBytesSync(value,
                                mode: FileMode.writeOnly);

                            // Fetch Request
                            await fetchResponse(file);
                            Duration duration = const Duration(seconds: 2);
                            await Future.delayed(duration, () {
                              if (kDebugMode) {
                                print('2 seconds passed');
                              }
                            });
                            setState(() {
                              loading = false;
                            });
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
              ],
            ),
    );
  }
}
