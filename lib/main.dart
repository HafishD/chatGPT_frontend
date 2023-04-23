import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

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
      title: 'Hackathon Monster Eggs',
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
                icon: Icon(Icons.photo),
                onPressed: () {
                  //処理
                  if (imageList.isNotEmpty){
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DisplayPictureScreen(imagePathList: imageList),
                        fullscreenDialog: true,
                      ),
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

class DisplayPictureScreen extends StatefulWidget{
  const DisplayPictureScreen({Key? key, required this.imagePathList})
  : super(key: key);

  final List<String> imagePathList;

  @override
  DisplayPictureScreenState createState() => DisplayPictureScreenState();
}

class DisplayPictureScreenState extends State<DisplayPictureScreen> {
  late String _path;
  late List<String> selected = [];

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
      appBar: AppBar(title: const Text('撮れた写真')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                height: 300,
                width: 300,
                child: GestureDetector(
                  child: Image.file(
                    File(_path),
                  ),
                  onTap: () {
                    if (selected.contains(_path)){
                      selected.removeWhere((element) => element == _path);
                    } else {
                      selected.add(_path);
                    }
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
                : selected.contains(path) ? Colors.blueAccent
                : Colors.white,
            width: 3.0,
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

