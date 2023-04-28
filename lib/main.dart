import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'take_picture.dart';

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
      title: 'PageShot',
      theme: ThemeData.light().copyWith(
        primaryColor: Color.fromARGB(255, 71, 78, 72),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.green,
      ),
      themeMode: ThemeMode.system,
      home: TakePictureScreen(camera: camera),
    );
  }
}
