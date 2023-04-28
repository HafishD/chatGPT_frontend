import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';


class DisplayResultScreen extends StatefulWidget {
  const DisplayResultScreen(
      {Key? key, required this.selectedImgPaths, required this.url})
      : super(key: key);

  final List<String> selectedImgPaths;
  final Uri url;

  @override
  DisplayResultScreenState createState() => DisplayResultScreenState();
}

class DisplayResultScreenState extends State<DisplayResultScreen> {
  late String _path;
  String _result = "";
  List<String> sentences = [];
  int index = 0;

  @override
  void initState() {
    super.initState();
    _path = widget.selectedImgPaths[0];
  }

  void changeState() {
    setState(() {
      _path = widget.selectedImgPaths[index];
      if (sentences.length >= 2){
        _result = sentences[index];
      }
    });
  }

  Future<List<String>> getData(url) async {
    List<String> results = [];
    Map<String, String> headers = {
      'Content-Type': 'application/json'
    };
    if (url == Uri.parse('https://chatgpt-backend-fmj2cdy42a-an.a.run.app/summarize')){
      List<String> base64Images = [];
      for (String imgPath in widget.selectedImgPaths) {
        File img = File(imgPath);
        // file -> base64
        List<int> imageBytes = img.readAsBytesSync();
        String base64Image = base64Encode(imageBytes);
        base64Images.add(base64Image);
      }

      String option = "summarize";

      String body = json.encode(
          {'post_imgs': base64Images, 'option': option});

      Response response = await http.post(url, headers: headers, body: body);

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String result = responseData['result'];

      results.add(result);
      return results;
    } else if (url == Uri.parse('https://chatgpt-backend-fmj2cdy42a-an.a.run.app/translate')){
      for (int i = 0; i < widget.selectedImgPaths.length; i++) {
        File img = File(widget.selectedImgPaths[i]);
        // file -> base64
        List<int> imageBytes = img.readAsBytesSync();
        String base64Image = base64Encode(imageBytes);

        String option = "translate";

        String body = json.encode(
            {'post_img': base64Image, 'option': option});

        // send to backend
        Response response = await http.post(url,
            headers: headers, body: body);

        final Map<String, dynamic> responseData =
        jsonDecode(response.body);
        final String result = responseData['result'];
        results.add(result);
      }
      return results;
    } else {
      return results;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData(widget.url),
      builder: (context, snapshot) {
        List<Widget> child;

        if (snapshot.hasData) {
          sentences = snapshot.data!;
          if (sentences.length >= 2){
            _result = sentences[index];
          } else {
            _result = sentences[0];
          }
          child = <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(
                File(_path),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Text(
                  _result,
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ];
        } else if (snapshot.hasError) {
          child = [
            const Center(
              child: Text('Connection Error: Please Try Again'),
            ),
          ];
        } else {
          child = [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text("Getting Results from ChatGPT"),
                ),
              ],
            ),
          ];
        }

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
                  Text('Page: ${(index + 1).toString()}'),
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
          body: ListView.builder(
            itemCount: child.length,
            itemBuilder: (context, index) {
              return child[index];
            },
          ),
        );
      },
    );
  }
}
