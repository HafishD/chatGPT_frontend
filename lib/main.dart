import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

Future<void> main() async {
  // main 関数内で非同期処理を呼び出すための設定
  WidgetsFlutterBinding.ensureInitialized();
  // デバイスで使用可能なカメラのリストを取得
  final cameras = await availableCameras();
  // 利用可能なカメラのリストから特定のカメラを取得
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hackathon: Monsters Eggs For Engineer',
      theme: ThemeData(),
      home: TakePictureScreen(camera: camera),
    );
  }
}

/// 写真撮影画面
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<String> imageList = [];

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      // カメラを指定
      widget.camera,
      // 解像度を定義
      ResolutionPreset.medium,
    );

    // コントローラーを初期化
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // ウィジェットが破棄されたら、コントローラーを破棄
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 写真を撮る
          final image = await _controller.takePicture();
          // 写真をリストに格納
          imageList.add(image.path);
        },
        child: const Icon(Icons.camera_alt),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: const Icon(Icons.photo),
                onPressed: () {
                  //処理
                  if (imageList.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            DisplayPictureScreen(imagePathList: imageList),
                        fullscreenDialog: true,
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('No Picture'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DisplayPictureScreen extends StatefulWidget {
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
  void initState() {
    super.initState();
    _path = widget.imagePathList[0];
  }

  void _changeState(String path) {
    setState(() {
      _path = path;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      if (selectedPath.contains(_path)) {
                        int index = selectedPath.indexOf(_path);
                        selected.removeAt(index);
                        selectedPath.removeWhere((element) => element == _path);
                      } else {
                        selected.add(File(_path));
                        selectedPath.add(_path);
                      }
                      setState(() {});
                    },
                  )),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < widget.imagePathList.length; i++) ...{
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
                    onPressed: () async {
                      results.clear();
                      List<String> base64Images = [];
                      for (File img in selected) {
                        // file -> base64
                        List<int> imageBytes = img.readAsBytesSync();
                        String base64Image = base64Encode(imageBytes);
                        base64Images.add(base64Image);
                      }

                      String option = "summarize";

                      Uri url =
                          Uri.parse('http://192.168.0.215:5050/translate');

                      String body = json.encode(
                          {'post_imgs': base64Images, 'option': option});

                      Map<String, String> headers = {
                        'Content-Type': 'application/json'
                      };

                      Response response =
                          await http.post(url, headers: headers, body: body);

                      final Map<String, dynamic> responseData =
                          jsonDecode(response.body);
                      final String result = responseData['result'];
                      results.add(result);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DisplayResultScreen(
                                sentences: results,
                                selectedImgPaths: selectedPath)),
                      );
                    },
                    child: const Text('Summarize')),
                ElevatedButton(
                    onPressed: () async {
                      results.clear();
                      for (int i = 0; i < selected.length; i++) {
                        File img = selected[i];
                        // file -> base64
                        List<int> imageBytes = img.readAsBytesSync();
                        String base64Image = base64Encode(imageBytes);

                        String option = "translate";

                        Uri url =
                            Uri.parse('http://192.168.0.215:5050/translate');

                        String body = json.encode(
                            {'post_img': base64Image, 'option': option});

                        Map<String, String> headers = {
                          'Content-Type': 'application/json'
                        };

                        // send to backend
                        Response response =
                            await http.post(url, headers: headers, body: body);

                        final Map<String, dynamic> responseData =
                            jsonDecode(response.body);
                        final String result = responseData['result'];
                        results.add(result);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DisplayResultScreen(
                                sentences: results,
                                selectedImgPaths: selectedPath)),
                      );
                    },
                    child: const Text('Translate'))
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
            color: _path == path
                ? Colors.redAccent
                : selectedPath.contains(path)
                    ? Colors.blueAccent
                    : Colors.white,
            width: selectedPath.contains(path) == true ? 3.0 : 1.0),
      ),
      child: GestureDetector(
        child: Image.file(
          File(path),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
        onTap: () {
          if (_path != path) _changeState(path);
        },
      ),
    );
  }
}

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
