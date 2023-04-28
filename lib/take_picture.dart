import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'display_picture.dart';

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
  FlashMode flashMode = FlashMode.off;
  bool isBlackout = false;

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

  void toggleFlash() {
    setState(() {
      switch (flashMode) {
        case FlashMode.off:
          flashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          flashMode = FlashMode.always;
          break;
        case FlashMode.always:
          flashMode = FlashMode.off;
          break;
      }
    });
    _controller.setFlashMode(flashMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              flashMode == FlashMode.off
                  ? Icons.flash_off
                  : flashMode == FlashMode.auto
                      ? Icons.flash_auto
                      : Icons.flash_on,
            ),
            onPressed: toggleFlash,
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
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
          if (isBlackout)
            Container(
              color: Color.fromARGB(255, 11, 11, 11).withOpacity(1.0),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            isBlackout = true;
          });
          // 写真を撮る
          final image = await _controller.takePicture();
          // 写真をリストに格納
          imageList.add(image.path);
          // await Future.delayed(const Duration(milliseconds: 200));
          setState(() {
            isBlackout = false;
          });
        },
        child: const Icon(Icons.camera_alt),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        // color: Color.fromARGB(255, 186, 211, 222).withOpacity(0),
        color: Theme.of(context).primaryColor,
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
