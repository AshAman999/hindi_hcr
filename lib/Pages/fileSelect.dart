// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hindi_hcr/Constants/constants.dart';
import 'package:hindi_hcr/Pages/result.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FileSelect extends StatefulWidget {
  const FileSelect({Key? key}) : super(key: key);

  @override
  State<FileSelect> createState() => _FileSelectState();
}

class _FileSelectState extends State<FileSelect> {
  XFile? _image;
  String response = "";
  bool loading = false;
  String predicted_handwriting = "";
  bool is_ocr = false;

  Future<void> _getImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    setState(() {
      _image = image;
    });
  }

  Future<void> fetchResponse(File file) async {
    // Fetch data from internet
    var uri = serverUrl + (is_ocr ? '/ocr' : '/hwcr');

    var request = http.MultipartRequest('POST', Uri.parse(uri));

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();

    var responded = await http.Response.fromStream(response);

    final responseData = json.decode(utf8.decode(responded.bodyBytes));
    if (kDebugMode) {
      print(responseData);
    }
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
        title: !loading ? const Text('Select Image from Gallery') : null,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          // horizontal: 20,
                          vertical: 40,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.deepOrange,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30),
                                child: Text(
                                  'IS OCR',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: CupertinoSwitch(
                                  value: is_ocr,
                                  onChanged: (value) {
                                    setState(
                                      () {
                                        is_ocr = value;
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_image != null)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.file(
                            File(_image!.path),
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: MediaQuery.of(context).size.height * 0.3,
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (_image == null)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            color: const Color.fromARGB(255, 187, 187, 187),
                          ),
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: const Center(
                            child: Text('No Image Selected'),
                          ),
                        ),
                      Container(
                        height: 80,
                      ),
                      CupertinoButton(
                        color: Colors.blueAccent,
                        onPressed: () => {
                          _getImageFromCamera(),
                        },
                        child: Text(_image == null ? " Gallery " : "ReSelect"),
                      ),
                      Container(
                        height: 40,
                      ),
                      CupertinoButton(
                          color: Colors.blueAccent,
                          child: const Text('Process'),
                          onPressed: () async {
                            if (_image == null) {
                              return;
                            }
                            setState(() {
                              loading = true;
                            });
                            final file = await File(_image!.path)
                                .create(recursive: true);
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
                          }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
