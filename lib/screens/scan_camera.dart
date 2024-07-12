import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:anidex/models/animal_info.dart';
import 'package:anidex/screens/animal_info.dart';
import 'package:anidex/utils.dart';
import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../components/phone_component.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  XFile? capturedImage; // Variable to store captured image path

  AnimationController? _captureAnimationController;
  Animation<double>? _captureAnimation;

  bool isConnected = true; // Flag to track internet connectivity
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  double _currentScale = 1.0; // Variable to store current zoom level
  double _baseScale = 1.0; // Variable to store initial zoom level

  bool isFlashOn = false; // Flag to track flash status

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _initializeCamera();
    _checkConnectivity();

    // Initialize capture animation controller
    _captureAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _captureAnimation = Tween<double>(begin: 1.0, end: 0.8)
        .animate(_captureAnimationController!);

    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      _updateConnectivityStatus(result);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    controller.dispose();
    _captureAnimationController!.dispose();
    _connectivitySubscription.cancel();
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

  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectivityStatus(connectivityResult);
  }

  void _updateConnectivityStatus(List<ConnectivityResult> result) {
    setState(() {
      isConnected = result[0] != ConnectivityResult.none;
    });
    if (!isConnected) {
      Fluttertoast.showToast(
        msg: "No internet connection. Image will be saved locally.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
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
                        style: titleStyles,
                      ),
                    ],
                  ),
                )
                    : Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onScaleStart: (details) {
                          _baseScale = _currentScale;
                        },
                        onScaleUpdate: (details) async {
                          setState(() {
                            _currentScale = _baseScale * details.scale;
                          });
                          final x = await controller.getMaxZoomLevel();

                          controller.setZoomLevel(_currentScale.clamp(1.0,x));
                        },
                        child: Stack(
                          children: [
                            CameraPreview(controller),
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
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    if (showButtons)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              capturedImage = null;
                              setState(() {});
                            },
                            icon: Icon(Icons.camera),
                            label: Text(
                              "Retake",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () async {
                              if (!isConnected) {
                                final x = await saveImageLocally(capturedImage!);
                                print(x);
                                Fluttertoast.showToast(
                                    msg: "Image saved locally. Data will be synced when internet is back.");
                                capturedImage = null;
                                setState(() {});
                                return;
                              }

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
                                final jsonString = value!.content!.parts!.last.text.toString();
                                final animalInfo = AnimalInfoModel.fromJson(jsonDecode(jsonString));
                                if (animalInfo.basicInformation!.commonName == "NA") {
                                  Fluttertoast.showToast(msg: "No animal found");
                                  setState(() {
                                    showLoader = false;
                                    showButtons = true;
                                  });
                                  return;
                                }
                                setState(() {
                                  showLoader = false;
                                  showButtons = true;
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnimalInfo(
                                      capturedImage: capturedImage!.path,
                                      animalInfoModel: animalInfo,
                                      isInfo: false,
                                    ),
                                  ),
                                );
                                // capturedImage = null;
                              }).catchError((e) {
                                print('textAndImageInput $e');
                                Fluttertoast.showToast(msg: "$e");

                                setState(() {
                                  showLoader = false;
                                  showButtons = true;
                                });
                              });
                            },
                            icon: Icon(Icons.check),
                            label: Text(
                              "Submit",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
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
          showLoader ? Container() :   Positioned(
            bottom: 120.0,
            right: MediaQuery.of(context).size.width /2.35,
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
         showLoader ? Container() : Positioned(
            top: 20.0,
            right: 20.0,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  isFlashOn = !isFlashOn;
                  controller.setFlashMode(isFlashOn ? FlashMode.torch : FlashMode.off);
                });
              },
              child: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            ),
          ),
          if (!isConnected)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.red,
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "No internet connection. Image will be saved locally.",
                    style: TextStyle(color: Colors.black),
                  ),
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

  Future<String?> saveImageLocally(XFile imageFile) async {
    try {
      // Get the local app directory path using path_provider
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Ensure directory exists
      await Directory(directory.path).create(recursive: true);

      // Read the file as bytes
      final bytes = await imageFile.readAsBytes();

      // Write the bytes to a new file
      final file = File(imagePath);
      await file.writeAsBytes(bytes);

      return imagePath;
    } catch (e) {
      print('Error saving image locally: $e');
      return null;
    }
  }
}

