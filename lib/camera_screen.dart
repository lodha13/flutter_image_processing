import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:imagerecog/detail_screen.dart';
import 'package:imagerecog/main.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ML Vision'),
      ),
      body: _controller.value.isInitialized
          ? buildScreen(_controller)
          : Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }

  Future<String> _takePicture() async {
    if (!_controller.value.isInitialized) {
      print("Controller is not initialized");
      return null;
    }

    String dateTime = DateFormat.yMMMd()
        .addPattern('-')
        .add_Hms()
        .format(DateTime.now())
        .toString();

    String formattedDateTime = dateTime.replaceAll(' ', '');
    print("formattedDate : $formattedDateTime");

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String visionDir = '${appDocDir.path}/Photos/Vision\ Images';
    await Directory(visionDir).create(recursive: true);
    final String imagePath = '$visionDir/image_$formattedDateTime.jpg';

    if (_controller.value.isTakingPicture) {
      print("Processing is in progress");
      return null;
    }

    try {
      final image = await _controller.takePicture();
      return image.path;
    } on CameraException catch (e) {
      print("Camera exception: $e");
      return null;
    }
    return null;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  buildScreen(CameraController _controller) {
    return Stack(
      children: <Widget>[
        CameraPreview(_controller),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            alignment: Alignment.bottomCenter,
            child: RaisedButton.icon(
              icon: Icon(Icons.camera),
              label: Text("Click"),
              onPressed: () async {
                await _takePicture().then((String path) {
                  if (path != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetailScreen(path)));
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
