import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../config.dart';
import 'package:camera_deep_ar/camera_deep_ar.dart';
import 'package:flutter/foundation.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // CameraDeepArControllerX cameraDeepArController;
  // Effects currentEffect = Effects.none;
  // Filters currentFilter = Filters.none;
  // Masks currentMask = Masks.empty;
  static Future<File> _loadFile(String path, String name) async {
    final ByteData data = await rootBundle.load(path);
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/$name');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return tempFile;
  }

  final deepArController = CameraDeepArController(config);
  String _platformVersion = 'Unknown';
  bool isRecording = false;
  CameraMode cameraMode = config.cameraMode;
  DisplayMode displayMode = config.displayMode;
  int currentEffect = 0;

  List get effectList {
    switch (cameraMode) {
      case CameraMode.mask:
        return masks;
        break;
      case CameraMode.effect:
        return effects;
        break;

      case CameraMode.filter:
        return filters;
        break;
      default:
        return masks;
    }
  }

  List masks = [
    "none",
    "assets/aviators",
    "assets/bigmouth",
    "assets/lion",
    "assets/dalmatian",
    "assets/bcgseg",
    "assets/look2",
    "assets/fatify",
    "assets/flowers",
    "assets/grumpycat",
    "assets/koala",
    "assets/mudmask",
    "assets/obama",
    "assets/pug",
    "assets/slash",
    "assets/sleepingmask",
    "assets/smallface",
    "assets/teddycigar",
    "assets/tripleface",
    "assets/twistedface",
  ];
  List effects = [
    "none",
    "assets/fire",
    "assets/heart",
    "assets/blizzard",
    "assets/rain",
  ];
  List filters = [
    "none",
    "assets/drawingmanga",
    "assets/sepia",
    "assets/bleachbypass",
    "assets/realvhs",
    "assets/filmcolorperfection"
  ];

  @override
  void initState() {
    super.initState();
    CameraDeepArController.checkPermissions();
    deepArController.setEventHandler(DeepArEventHandler(onCameraReady: (v) {
      _platformVersion = "onCameraReady $v";
      setState(() {});
    }, onSnapPhotoCompleted: (v) {
      _platformVersion = "onSnapPhotoCompleted $v";
      setState(() {});
    }, onVideoRecordingComplete: (v) {
      _platformVersion = "onVideoRecordingComplete $v";
      setState(() {});
    }, onSwitchEffect: (v) {
      _platformVersion = "onSwitchEffect $v";
      setState(() {});
    }));
  }

  @override
  void dispose() {
    deepArController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.red.shade300,
          title: const Text('VIỆT NAM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),),
        ),
        body: Stack(
          children: [
            DeepArPreview(deepArController),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.all(20),
                //height: 250,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Response : $_platformVersion\n',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    if (null == deepArController) return;
                                    if (isRecording) return;
                                    deepArController.snapPhoto();
                                  },
                                  icon: Icon(Icons.camera_enhance_outlined),
                                  padding: EdgeInsets.all(15),
                                ),
                              )
                          ),
                          if (displayMode == DisplayMode.image)
                            Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(10),
                                  ),

                                  child: IconButton(
                                    onPressed: () async {
                                      String path = "assets/testImage.jpg";
                                      final file = await deepArController.createFileFromAsset(path, "test");

                                      // final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                                      await Future.delayed(Duration(seconds: 1));

                                      deepArController.changeImage(file.path);
                                      print("DAMON - Calling Change Image Flutter");
                                    },
                                    icon: Icon(Icons.image),
                                    color: Colors.orange,
                                    padding: EdgeInsets.all(15),
                                  ),
                                )
                            ),
                          if (isRecording)
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.deepOrangeAccent,
                                  borderRadius: BorderRadius.circular(10),
                                ),

                                child: IconButton(
                                  onPressed: () {
                                    if (null == deepArController) return;
                                    deepArController.stopVideoRecording();
                                    isRecording = false;
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.videocam_off),
                                  color: Colors.black,
                                  padding: EdgeInsets.all(15),
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.lime,
                                  borderRadius: BorderRadius.circular(10),
                                ),

                                child: IconButton(
                                  onPressed: () {
                                    if (null == deepArController) return;
                                    deepArController.startVideoRecording();
                                    isRecording = true;
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.videocam),
                                  color: Colors.black,
                                  padding: EdgeInsets.all(15),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SingleChildScrollView(
                      padding: EdgeInsets.all(15),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(effectList.length, (p) {
                          bool active = currentEffect == p;
                          String imgPath = effectList[p];
                          return GestureDetector(
                            onTap: () async {
                              if (!deepArController.value.isInitialized) return;
                              currentEffect = p;
                              deepArController.switchEffect(
                                  cameraMode, imgPath);
                              setState(() {});
                            },
                            child: Container(
                              margin: EdgeInsets.all(6),
                              width: active ? 70 : 55,
                              height: active ? 70 : 55,
                              alignment: Alignment.center,
                              child: Text(
                                "$p",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: active ? FontWeight.bold : null,
                                    fontSize: active ? 16 : 14,
                                    color:
                                    active ? Colors.white : Colors.black),
                              ),
                              decoration: BoxDecoration(
                                  color: active ? Colors.orange.shade300 : Colors.white,
                                  border: Border.all(
                                      color:
                                      active ? Colors.orange.shade300 : Colors.white,
                                      width: active ? 2 : 0),
                                  shape: BoxShape.circle),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: List.generate(CameraMode.values.length, (p) {
                        CameraMode mode = CameraMode.values[p];
                        bool active = cameraMode == mode;
                        return Expanded(
                          child: Container(
                            height: 40,
                            margin: EdgeInsets.all(2),
                            child: TextButton(
                              onPressed: () async {
                                cameraMode = mode;
                                setState(() {});
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey.shade800,
                                primary: Colors.grey.shade800,
                                // shape: CircleBorder(
                                //     side: BorderSide(
                                //         color: Colors.white, width: 3))
                              ),
                              child: Text(
                                describeEnum(mode),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: active ? FontWeight.bold : null,
                                    fontSize: active ? 16 : 14,
                                    color: Colors.white
                                        .withOpacity(active ? 1 : 0.6)),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    // Row(
                    //   children: List.generate(DisplayMode.values.length, (p) {
                    //     DisplayMode mode = DisplayMode.values[p];
                    //     bool active = displayMode == mode;
                    //
                    //     return Expanded(
                    //       child: Container(
                    //         height: 40,
                    //         margin: EdgeInsets.all(2),
                    //         child: TextButton(
                    //           onPressed: () async {
                    //             displayMode = mode;
                    //             await deepArController.setDisplayMode(
                    //                 mode: mode);
                    //             setState(() {});
                    //           },
                    //           style: TextButton.styleFrom(
                    //             backgroundColor: Colors.purple,
                    //             primary: Colors.black,
                    //             // shape: CircleBorder(
                    //             //     side: BorderSide(
                    //             //         color: Colors.white, width: 3))
                    //           ),
                    //           child: Text(
                    //             describeEnum(mode),
                    //             textAlign: TextAlign.center,
                    //             style: TextStyle(
                    //                 fontWeight: active ? FontWeight.bold : null,
                    //                 fontSize: active ? 16 : 14,
                    //                 color: Colors.white
                    //                     .withOpacity(active ? 1 : 0.6)),
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   }),
                    // )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }}
