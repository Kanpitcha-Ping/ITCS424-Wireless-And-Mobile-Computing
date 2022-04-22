import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:face_recog_auth/pages/db/db_firebase.dart';
import 'package:face_recog_auth/pages/models/user.model.dart';
import 'package:face_recog_auth/services/image_converter.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;

class MLService {

  Interpreter _interpreter;
  double threshold = 0.6;

  List _predictedData = [];
  List get predictedData => _predictedData;
  List<User> Repo = [];

  Future loadModel() async {
    Delegate delegate;
    try {
      if (Platform.isAndroid) {
        delegate = GpuDelegateV2(
            options: GpuDelegateOptionsV2(
              isPrecisionLossAllowed: false,
              inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
              inferencePriority1: TfLiteGpuInferencePriority.minLatency,
              inferencePriority2: TfLiteGpuInferencePriority.auto,
              inferencePriority3: TfLiteGpuInferencePriority.auto,
            ));
      } else if (Platform.isIOS) {
        delegate = GpuDelegate(
          options: GpuDelegateOptions(allowPrecisionLoss: true, waitType: TFLGpuDelegateWaitType.active),
        );
      }
      var interpreterOptions = InterpreterOptions()..addDelegate(delegate);

      this._interpreter = await Interpreter.fromAsset('mobilefacenet.tflite',
          options: interpreterOptions);
      print('model loaded successfully');
    } catch (e) {
      print('Failed to load model.');
      print(e);
    }
  }

  void setCurrentPrediction(CameraImage cameraImage, Face face) {
    if (_interpreter == null) throw Exception('Interpreter is null');
    if (face == null) throw Exception('Face is null');

    List input = _preProcess(cameraImage, face);

    input = input.reshape([1, 112, 112, 3]);
    List output = List.generate(1, (index) => List.filled(192, 0));

    this._interpreter.run(input, output);
    output = output.reshape([192]);

    this._predictedData = List.from(output);
  }

  // fetchDB() async {
  //   dynamic usersList = await StudentsRepository().queryAllUsers();
  //   if (usersList == null) {
  //     print("Cannot fetch db");
  //   } else {
  //     Repo = usersList;
  //     print("Repo: " + Repo.isNotEmpty.toString());
  //   }
  // }

  Future<User> predict(List<User> repo) async {
    print("ML_service: get in to predict()");
    this.Repo = repo;
    // await fetchDB();
    // print("fecth db!");
    // print("after fetching: " + Repo.isNotEmpty.toString());
    return await _searchResult(_predictedData); //potential unmount problem
  }

  List _preProcess(CameraImage image, Face faceDetected) {
    imglib.Image croppedImage = _cropFace(image, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, 112);

    Float32List imageAsList = imageToByteListFloat32(img);
    return imageAsList;
  }

  imglib.Image _cropFace(CameraImage image, Face faceDetected) {
    imglib.Image convertedImage = _convertCameraImage(image);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return imglib.copyCrop(
        convertedImage, x.round(), y.round(), w.round(), h.round());
  }

  imglib.Image _convertCameraImage(CameraImage image) {
    var img = convertToImage(image);
    var img1 = imglib.copyRotate(img, -90);
    return img1;
  }

  Float32List imageToByteListFloat32(imglib.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (imglib.getRed(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getGreen(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getBlue(pixel) - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

  Future<User> _searchResult(List predictedData) async {
    print("ML_service: get in to searchResult");
    // StudentsRepository _stdRepo = StudentsRepository();
    // List<User> users = await _stdRepo.queryAllUsers(); //err here
    print(Repo); //potential unmount problem

    double minDist = 999;
    double currDist = 0.0;
    User predictedResult;

    for (User u in Repo) {
      print("ml_service (u): " + u.getUsername());
      currDist = await _euclideanDistance(u.modelData, predictedData);
      print("euc distance: " + currDist.toString());
      print("th" + threshold.toString());
      print("minDist: " + minDist.toString());
      if (currDist <= threshold && currDist < minDist) {
        print("ml_service: found match user");
        minDist = currDist;
        predictedResult = u;
      }
    }
    //print("ml_service (user): " + predictedResult.getUsername());
    return predictedResult;
  }

  Future<double> _euclideanDistance(List e1, List e2) async {
    print("ml_service: euc");
    print(e1);
    print(e2);
    if (e1 == null || e2 == null) throw Exception("Null argument");

    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }

  void setPredictedData(value) {
    this._predictedData = value;
  }

  dispose() {}
}
