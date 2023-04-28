import 'dart:io';

import 'package:flutter/material.dart';

class DisplayResultScreen extends StatefulWidget {
  const DisplayResultScreen(
      {Key? key, required this.sentences, required this.selectedImgPaths})
      : super(key: key);

  final List<String> sentences;
  final List<String> selectedImgPaths;

  @override
  DisplayResultScreenState createState() => DisplayResultScreenState();
}

class DisplayResultScreenState extends State<DisplayResultScreen> {
  late String _path;
  late String _result;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _path = widget.selectedImgPaths[0];
    _result = widget.sentences[0];
  }

  void changeState() {
    setState(() {
      _path = widget.selectedImgPaths[index];
      if (widget.sentences.length >= 2) {
        _result = widget.sentences[index];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Result'),
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            '< Back',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: const Icon(Icons.camera_alt),
      ),
      persistentFooterButtons: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (index > 0) {
                    index--;
                  } else {
                    index = widget.selectedImgPaths.length - 1;
                  }
                  changeState();
                },
                child: const Text(
                  '<',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (index < widget.selectedImgPaths.length - 1) {
                    index++;
                  } else {
                    index = 0;
                  }
                  changeState();
                },
                child: const Text(
                  '>',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(
                File(_path),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Text(
                  _result,
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
