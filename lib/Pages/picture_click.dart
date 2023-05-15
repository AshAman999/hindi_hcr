import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PictureClick extends StatefulWidget {
  const PictureClick({super.key});

  @override
  State<PictureClick> createState() => _PictureClickState();
}

class _PictureClickState extends State<PictureClick> {
  XFile? _image;

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
              child: Image.file(
                File(_image!.path),
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.3,
                fit: BoxFit.contain,
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
          GestureDetector(
            onTap: () => {
              _getImageFromCamera(),
            },
            child: Text(_image == null ? "Take Image" : "Retake Image"),
          ),
          Container(
            height: 40,
          ),
          GestureDetector(
            onTap: () => {
              debugPrint("Process"),
            },
            child: const Text("Process"),
          )
        ],
      )),
    );
  }
}
