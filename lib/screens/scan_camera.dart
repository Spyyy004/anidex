import 'dart:convert';
import 'dart:io';

import 'package:anidex/models/animal_info.dart';
import 'package:anidex/screens/animal_info.dart';
import 'package:anidex/utils.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class CameraExampleHome extends StatefulWidget {
  const CameraExampleHome({Key? key}) : super(key: key);

  @override
  State<CameraExampleHome> createState() => _CameraExampleHomeState();
}

class _CameraExampleHomeState extends State<CameraExampleHome>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late CameraController controller;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> _cameras;
  bool showLoader = false;
  bool showButtons = false;
  XFile? capturedImage; // Variable to store captured image path

  AnimationController? _captureAnimationController;
  Animation<double>? _captureAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _initializeCamera();

    // Initialize capture animation controller
    _captureAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _captureAnimation = Tween<double>(begin: 1.0, end: 0.8)
        .animate(_captureAnimationController!);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    controller.dispose();
    _captureAnimationController!.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      controller = CameraController(_cameras[0], ResolutionPreset.max);
      _initializeControllerFuture = controller.initialize();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return showLoader
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        "Hang on! Fetching animal details.",
                        style: header3Styles,
                      ),
                    ],
                  ),
                )
                    : Column(
                  children: [
                    Expanded(
                      child: CameraPreview(controller),
                    ),
                    SizedBox(height: 16),
                    if (showButtons)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton(
                            style: buttonStyles,
                            onPressed: () {
                              capturedImage = null;
                              setState(() {});
                            },
                            child: Text(
                              "Retake",
                              style: regularTitleStyles.merge(
                                TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          OutlinedButton(
                            style: buttonStyles,
                            onPressed: () {

                              final file = File(capturedImage!.path);


                              setState(() {
                                showLoader = true;
                                showButtons = false;
                              });


                              gemini
                                  .textAndImage(
                                text: prompt,
                                images: [file.readAsBytesSync()],
                              )
                                  .then((value) {
                                print("HEYOO23 $value");
                                final jsonString =
                                value!.content!.parts!.last.text
                                    .toString();
                                print("yoheee $jsonString");
                                final jsonDecoded =
                                jsonDecode(jsonString);
                                final animalInfo =
                                AnimalInfoModel.fromJson(
                                    jsonDecode(jsonString));
                                if(animalInfo.basicInformation!.commonName == "NA"){
                                  Fluttertoast.showToast(msg: "No animal found");
                                  setState(() {
                                    showLoader = false;
                                    showButtons = true;
                                  });

                                }
                                setState(() {
                                  showLoader = false;
                                  showButtons = true;
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AnimalInfo(
                                          capturedImage: capturedImage!.path,
                                          animalInfoModel: animalInfo,
                                          isInfo: false,
                                        ),
                                  ),
                                );
                              })
                                  .catchError((e) {
                                print('textAndImageInput $e');
                                Fluttertoast.showToast(msg: "$e");

                                setState(() {
                                  showLoader = false;
                                  showButtons = true;
                                });
                              });
                            },
                            child: Text(
                              "Submit",
                              style: regularTitleStyles.merge(
                                TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          if (!showLoader && capturedImage != null)
            Positioned(
              bottom: 120.0,
              left: 20.0,
              child: Container(
                height: 100.0,
                width: 100.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: FileImage(File(capturedImage!.path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 120.0,
            right: 20.0,
            child: ScaleTransition(
              scale: _captureAnimation!,
              child: FloatingActionButton(
                child: const Icon(Icons.camera_alt),
                onPressed: () async {
                  _captureAnimationController!.forward();
                  await Future.delayed(const Duration(milliseconds: 200));
                  capturedImage = await controller.takePicture();
                  showButtons = true;
                  _captureAnimationController!.reverse();
                  setState(() {});
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('No animal found. Please try again.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
