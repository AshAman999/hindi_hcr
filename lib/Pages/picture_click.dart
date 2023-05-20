import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:hindi_hcr/Constants/constants.dart';
import 'package:hindi_hcr/Pages/result.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PictureClick extends StatefulWidget {
  const PictureClick({super.key});

  @override
  State<PictureClick> createState() => _PictureClickState();
}

class _PictureClickState extends State<PictureClick> {
  XFile? _image;

  String response = "";

  Future<void> _getImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return;
    }
    setState(() {
      _image = image;
    });
  }

  Future<void> fetchResponse(File file) async {
    // Fetch data from internet
    var uri = '$serverUrl/upload_image/';

    var request = http.MultipartRequest('POST', Uri.parse(uri));

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var resp = await request.send();
// set loading to be false
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Image from Camera'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
            child: Text(_image == null ? "Capture" : "Retake"),
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
                // set loading to be true
                final file = await File(_image!.path).create(recursive: true);

                // Fetch Request
                await fetchResponse(file);

                // ignore: use_build_context_synchronously
                if (!context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(
                      file: file,
                      response: response,
                    ),
                  ),
                );
              }),
        ],
      )),
    );
  }
}
