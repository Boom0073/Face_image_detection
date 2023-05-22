import 'dart:io';
import 'dart:ui';
import 'package:face_image_detection_practice10/interfaces/show_image/show_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

class MyCamera extends StatefulWidget {
  const MyCamera({super.key});

  @override
  State<MyCamera> createState() => _MyCameraState();
}

class _MyCameraState extends State<MyCamera> {
  late final ImagePicker _imagePicker = ImagePicker();
  late final FaceDetector _faceDetector;
  File? _imageFileFromCamera;
  Image? _imageUI;
  List<Face>? _faces;
  String result = 'Result will be shown here';

  @override
  void initState() {
    final FaceDetectorOptions options = FaceDetectorOptions(
      enableClassification: true,
      enableContours: true,
      enableLandmarks: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    );
    _faceDetector = FaceDetector(options: options);
    super.initState();
  }

  Future<void> _chooseImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _imageFileFromCamera = File(image.path);
      await _doFaceImageDetection(_imageFileFromCamera!);
      await _drawImageUIWithFaceIndication(_imageFileFromCamera!);
    } else {
      return;
    }
  }

  Future<void> _captureImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _imageFileFromCamera = File(image.path);
      await _doFaceImageDetection(_imageFileFromCamera!);
      await _drawImageUIWithFaceIndication(_imageFileFromCamera!);
    } else {
      return;
    }
  }

  Future<void> _doFaceImageDetection(File imageFile) async {
    final InputImage inputImage = InputImage.fromFile(imageFile);
    _faces = await _faceDetector.processImage(inputImage);
    if (_faces != null) {
      result = '';
      if (_faces!.isNotEmpty) {
        for (final Face face in _faces!) {
          if (face.smilingProbability != null) {
            if (face.smilingProbability! > 0.5) {
              result += 'Smile\n';
            } else {
              result += 'Not-Smile\n';
            }
          } else {
            result += 'Cannot identify mood\n';
          }
        }
      } else {
        result += 'Do not have any faces\n';
      }
      setState(() => result);
    }
  }

  Future<void> _drawImageUIWithFaceIndication(File imageFile) async {
    final Uint8List imageAsBytes = await imageFile.readAsBytes();
    _imageUI = await decodeImageFromList(imageAsBytes);
    setState(() => _imageUI);
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        final maxWidth = constraint.maxWidth;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShowImage(
                faces: _faces,
                imageUI: _imageUI,
                width: maxWidth,
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: _chooseImage,
                onLongPress: _captureImage,
                child: const Text(
                  'Choose/Capture',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(result, textAlign: TextAlign.center)
            ],
          ),
        );
      },
    );
  }
}
