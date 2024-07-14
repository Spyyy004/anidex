import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:anidex/models/animal_info.dart';
import 'package:anidex/screens/animal_info.dart';
import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../components/phone_component.dart';
import '../utils.dart';

class CameraExampleHome extends StatefulWidget {
  const CameraExampleHome({Key? key}) : super(key: key);

  @override
  State<CameraExampleHome> createState() => _CameraExampleHomeState();
}

class _CameraExampleHomeState extends State<CameraExampleHome>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late CameraController controller;
  Future<void>? _initializeControllerFuture;
  late List<CameraDescription> _cameras;
  bool showLoader = false;
  bool showButtons = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  XFile? capturedImage;
  final ImagePicker _picker = ImagePicker();

  AnimationController? _captureAnimationController;
  Animation<double>? _captureAnimation;

  bool isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  double _currentScale = 1.0;
  double _baseScale = 1.0;

  bool isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _initializeCamera();
    _checkConnectivity();

    _captureAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _captureAnimation = Tween<double>(begin: 1.0, end: 0.8)
        .animate(_captureAnimationController!);

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      _updateConnectivityStatus(result[0]);
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
    CameraDescription? backCamera;
    for (var camera in _cameras) {
      if (camera.lensDirection == CameraLensDirection.back) {
        backCamera = camera;
        break;
      }
      else {
        backCamera = _cameras[0];
      }
    }

    if (backCamera != null) {
      controller = CameraController(backCamera , ResolutionPreset.max);
      _initializeControllerFuture = controller.initialize();
      setState(() {});
      return _initializeControllerFuture;
    } else {
      Fluttertoast.showToast(
        msg: "No back camera found",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectivityStatus(connectivityResult[0]);
  }

  void _updateConnectivityStatus(ConnectivityResult result) {
    setState(() {
      isConnected = result != ConnectivityResult.none;
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

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        capturedImage = XFile(pickedFile.path);
        showButtons = true;
      });
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
                return _buildCameraPreview();
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Positioned(
            bottom: capturedImage != null ? 80 : 50.0,
            right: MediaQuery.of(context).size.width / 4,
            child: _buildCaptureButton(),
          ),
          Positioned(
            top: 50.0,
            right: 20.0,
            child: _buildFlashButton(),
          ),
          Positioned(
            bottom: capturedImage != null ? 80 :  50.0,
            left: MediaQuery.of(context).size.width / 4,
            child: _buildGalleryButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
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
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                  ),
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
                    final maxZoom = await controller.getMaxZoomLevel();
                    controller.setZoomLevel(_currentScale.clamp(1.0, maxZoom));
                  },
                  child: Stack(
                    children: [
                      Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: CameraPreview(controller)),
                      if (!showLoader && capturedImage != null)
                       kIsWeb ?
                       Positioned(
                          top: 20.0,
                          left: 0.0,
                          child: FutureBuilder<Uint8List?>(
                            future: _getBytesFromFile(capturedImage!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.data != null) {
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit
                                      .cover, // Adjust as per your requirement
                                  width:
                                      100, // Adjust width as per your requirement
                                  height:
                                      100, // Adjust height as per your requirement
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                        ) :
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
              if (showButtons) _buildActionButtons(),
            ],
          );
  }

  Widget _buildCaptureButton() {
    return showLoader
        ? Container()
        : ScaleTransition(
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
          );
  }

  Widget _buildFlashButton() {
    return showLoader
        ? Container()
        : IconButton(
            icon: Icon(
              Icons.flash_on,
              color: isFlashOn ? Colors.yellow : Colors.white,
            ),
            onPressed: () async {
              setState(() {
                isFlashOn = !isFlashOn;
              });
              await controller.setFlashMode(
                isFlashOn ? FlashMode.torch : FlashMode.off,
              );
            },
          );
  }

  Widget _buildGalleryButton() {
    return showLoader
        ? Container()
        : ScaleTransition(
            scale: _captureAnimation!,
            child: FloatingActionButton(
              child: const Icon(Icons.photo),
              onPressed: _pickImageFromGallery,
            ),
          );
  }

  Widget _buildActionButtons() {
    return Row(
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
            showButtons = false;
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
              final localPath = await saveImageLocally(capturedImage!);
              print(localPath);
              Fluttertoast.showToast(
                  msg:
                      "Image saved locally. Data will be synced when internet is back.");
              capturedImage = null;
              setState(() {});
              return;
            }

            final file = File(capturedImage!.path);

            setState(() {
              showLoader = true;
              showButtons = false;
            });
            final bytes = await capturedImage?.readAsBytes();
            gemini.textAndImage(
              text: prompt,
              images: [kIsWeb ? bytes! : file.readAsBytesSync()],
            ).then((value) {
              final jsonString = value!.content!.parts!.last.text.toString();
              final animalInfo =
                  AnimalInfoModel.fromJson(jsonDecode(jsonString));
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
                    capturedImage: capturedImage!,
                    animalInfoModel: animalInfo,
                    isInfo: false,
                  ),
                ),
              );
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
    );
  }

  Future<String?> saveImageLocally(XFile imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await Directory(directory.path).create(recursive: true);

      final bytes = await imageFile.readAsBytes();

      final file = File(imagePath);
      await file.writeAsBytes(bytes);

      return imagePath;
    } catch (e) {
      print('Error saving image locally: $e');
      return null;
    }
  }

  Future<Uint8List?> _getBytesFromFile(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      return bytes;
    } catch (e) {
      print('Error reading file: $e');
      return null;
    }
  }
}
