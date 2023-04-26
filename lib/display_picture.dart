import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'display_result.dart';

class DisplayPictureScreen extends StatefulWidget{
  const DisplayPictureScreen({Key? key, required this.imagePathList})
      : super(key: key);

  final List<String> imagePathList;

  @override
  DisplayPictureScreenState createState() => DisplayPictureScreenState();
}

class DisplayPictureScreenState extends State<DisplayPictureScreen> {
  late String _path;
  List<File> selected = [];
  List<String> selectedPath = [];
  List<String> results = [];

  @override
  void initState(){
    super.initState();
    _path = widget.imagePathList[0];
  }

  void _changeState(String path){
    setState((){
      _path = path;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Pictures')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 300,
                  width: 300,
                  child: GestureDetector(
                    child: Image.file(
                      File(_path),
                    ),
                    onTap: () {
                      if (selectedPath.contains(_path)){
                        int index = selectedPath.indexOf(_path);
                        selected.removeAt(index);
                        selectedPath.removeWhere((element) => element == _path);
                      } else {
                        selected.add(File(_path));
                        selectedPath.add(_path);
                      }
                      setState(() {});
                    },
                  )
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for(int i = 0; i < widget.imagePathList.length; i++) ... {
                    smallImage(widget.imagePathList[i])
                  }
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () async{
                      results.clear();
                      List<String> base64Images = [];
                      for (File img in selected) {
                        // file -> base64
                        List<int> imageBytes = img.readAsBytesSync();
                        String base64Image = base64Encode(imageBytes);
                        base64Images.add(base64Image);
                      }

                      String option = "summarize";

                      Uri url = Uri.parse('https://chatgpt-backend-fmj2cdy42a-an.a.run.app/summarize');

                      String body = json.encode({
                        'post_imgs': base64Images,
                        'option': option
                      });

                      Map<String, String> headers = {
                        'Content-Type': 'application/json'
                      };

                      Response response = await http.post(url, headers: headers, body: body);


                      final Map<String, dynamic> responseData = jsonDecode(response.body);
                      final String result = responseData['result'];
                      results.add(result);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DisplayResultScreen(sentences: results, selectedImgPaths: selectedPath)),
                      );
                    },
                    child: const Text('Summarize')
                ),
                ElevatedButton(
                    onPressed: () async{
                      results.clear();
                      for (int i = 0; i < selected.length; i++) {
                        File img = selected[i];
                        // file -> base64
                        List<int> imageBytes = img.readAsBytesSync();
                        String base64Image = base64Encode(imageBytes);

                        String option = "translate";

                        Uri url = Uri.parse('https://chatgpt-backend-fmj2cdy42a-an.a.run.app/translate');

                        String body = json.encode({
                          'post_img': base64Image,
                          'option': option
                        });

                        Map<String, String> headers = {
                          'Content-Type': 'application/json'
                        };

                        // send to backend
                        Response response = await http.post(url, headers: headers, body: body);


                        final Map<String, dynamic> responseData = jsonDecode(response.body);
                        final String result = responseData['result'];
                        results.add(result);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DisplayResultScreen(sentences: results, selectedImgPaths: selectedPath)),
                      );
                    },
                    child: const Text('Translate')
                )
              ],
            )
          ],
        ),
      ),
    );
  }
  Widget smallImage(String path) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: _path == path ? Colors.redAccent
                : selectedPath.contains(path) ? Colors.blueAccent
                : Colors.white,
            width: selectedPath.contains(path) == true ? 3.0
                : 1.0
        ),
      ),
      child: GestureDetector(
        child: Image.file(
          File(path),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
        onTap: () {
          if(_path!=path)_changeState(path);
        },
      ),
    );
  }
}