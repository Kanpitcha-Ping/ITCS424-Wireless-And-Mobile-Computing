import 'package:face_recog_auth/locator.dart';
import 'package:face_recog_auth/pages/db/db_firebase.dart';
import 'package:face_recog_auth/pages/models/user.model.dart';
import 'package:face_recog_auth/pages/profile.dart';
import 'package:face_recog_auth/pages/widgets/app_button.dart';

import 'package:face_recog_auth/services/camera.service.dart';
import 'package:face_recog_auth/services/ml_service.dart';
import 'package:flutter/material.dart';
import '../home.dart';
import 'app_text_field.dart';

class AuthActionButton extends StatefulWidget {

  const AuthActionButton(@required this._initializeControllerFuture,
      {Key key,@required this.onPressed, @required this.isLogin, this.reload, this.Repo});
  final Future _initializeControllerFuture;
  //this._initializeControllerFuture,
  final Function onPressed;
  final bool isLogin;
  final Function reload;
  final List<User> Repo;

  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  final MLService _mlService = locator<MLService>();
  final CameraService _cameraService = locator<CameraService>();

  final TextEditingController _userTextEditingController =
      TextEditingController(text: '');
  final TextEditingController _passwordTextEditingController =
      TextEditingController(text: '');
  final TextEditingController _emailTextEditingController =
  TextEditingController(text: '');

  User predictedUser;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future _signUp(context) async {
    StudentsRepository _stdRepo = StudentsRepository();

    /// gets predicted data from facenet service (user face detected)
    List predictedData = _mlService.predictedData; //modeldata
    String user = _userTextEditingController.text;
    String password = _passwordTextEditingController.text;
    String email = _emailTextEditingController.text;

    User userToSave = User(
      user: user,
      password: password,
      modelData: predictedData,
      email: email,
    );
    await _stdRepo.insert(userToSave);

    /// resets the face stored in the face net service
    this._mlService.setPredictedData(null);
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => MyHomePage()));
  }

  Future _signIn(context) async {
    String password = _passwordTextEditingController.text;
    print("come to _signIn");
    if (predictedUser.password == password) {
      print("password macth!");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => Profile(
                    predictedUser,
                    imagePath: _cameraService.imagePath,
                  )));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Wrong password!'),
          );
        },
      );
    }
  }

  Future<User> _predictUser() async {
    User userAndPass = await _mlService.predict(widget.Repo);
    return userAndPass;
  }

  Future onTap() async {
    try {
      // Ensure that the camera is initialized.
      await widget._initializeControllerFuture;
      // onShot event (takes the image and predict output)
      bool faceDetected = await widget.onPressed();
      print(faceDetected);
      if (faceDetected) {
        print("face detected");
        print(widget.isLogin);

        if (widget.isLogin) {
          User user = await _predictUser();
          if (user != null) {
            predictedUser = user;
            print("predictedUser: " + predictedUser.user);
          }
        }
        PersistentBottomSheetController bottomSheetController = Scaffold.of(context).showBottomSheet((context) => signSheet(context));
        bottomSheetController.closed.whenComplete(() => widget.reload());
      }
    } catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFF0F0BDB),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'CAPTURE',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.camera_alt, color: Colors.white)
          ],
        ),
      ),
    );
  }


  signSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.isLogin && predictedUser != null
              ? Container(
                  child: Text(
                    'Welcome back, ' + predictedUser.user + '.',
                    style: const TextStyle(fontSize: 20),
                  ),
                )
              : widget.isLogin
                  ? Container(
                      child: const Text(
                      'User not found 😞',
                      style: TextStyle(fontSize: 20),
                    ))
                  : Container(),
          Container(
            child: Column(
              children: [
                !widget.isLogin
                    ? AppTextField(
                        controller: _userTextEditingController,
                        labelText: "Your Name",
                      )
                    : Container(),
                SizedBox(height: 10),
                widget.isLogin && predictedUser == null
                    ? Container()
                    : AppTextField(
                        controller: _passwordTextEditingController,
                        labelText: "Password",
                        isPassword: true,
                      ),
                SizedBox(height: 10),
                !widget.isLogin
                    ? AppTextField(
                        controller: _emailTextEditingController,
                        labelText: "Email",
                      )
                    : Container(),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                widget.isLogin && predictedUser != null
                    ? AppButton(
                        text: 'LOGIN',
                        onPressed: () async {
                          await _signIn(context);
                        },
                        icon: const Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                      )
                    : !widget.isLogin
                        ? AppButton(
                            text: 'SIGN UP',
                            onPressed: () async {
                              await _signUp(context);
                            },
                            icon: const Icon(
                              Icons.person_add,
                              color: Colors.white,
                            ),
                          )
                        : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
