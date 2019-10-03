import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:telfaza/services/db_service.dart';
import 'package:telfaza/style.dart';
import 'package:validators/validators.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _usernameController;
  TextEditingController _nameController;
  String _email;
  String _username;
  String _name;
  String _photoUrl;
  File _photo;
  bool _loading = false;
  bool _imageLoading = false;
  DBService _dbService;

  final usernameReg = RegExp('^[a-zA-Z0-9]+([._]?[a-zA-Z0-9]+)*\$');
  final dotsReg = RegExp('[.]{2,}');
  final underScoresReg = RegExp('[_]{2,}');
  final nameReg = RegExp('^[a-zA-Z]*\$');

  @override
  void initState() {
    super.initState();
    _email = widget.user.email;
    _username = widget.user.username;
    _name = widget.user.name;
    _photoUrl = widget.user.photoUrl;

    _usernameController =
        TextEditingController.fromValue(TextEditingValue(text: _username));
    _nameController =
        TextEditingController.fromValue(TextEditingValue(text: _name));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dbService = Provider.of<DBService>(context);
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: ModalProgressHUD(
        inAsyncCall: _loading || _imageLoading,
        progressIndicator: Container(),
        opacity: _imageLoading ? 0.5 : 0.0,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text('Profile'),
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              icon: Icon(Icons.clear),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _saveProfile();
                  }
                },
                icon:
                    _loading ? CircularProgressIndicator() : Icon(Icons.check),
              )
            ],
          ),
          body: Theme(
            data: appTheme.copyWith(
              inputDecorationTheme: InputDecorationTheme(
                hintStyle: TextStyle(
                  color: Colors.white54,
                ),
                labelStyle: TextStyle(
                  color: Colors.white70,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white70,
                  ),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white24,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: kSecondaryColor,
                  ),
                ),
              ),
            ),
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(3.0),
                              child: CircleAvatar(
                                backgroundImage: _photo == null
                                    ? CachedNetworkImageProvider(
                                        _photoUrl,
                                      )
                                    : FileImage(_photo),
                                radius: 50.0,
                                child: _imageLoading
                                    ? CircularProgressIndicator()
                                    : Container(),
                              ),
                            ),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _changePhoto,
                                  customBorder: CircleBorder(),
                                  splashColor: kSecondaryColor.withAlpha(0x55),
                                  highlightColor: Colors.transparent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                        TextFormField(
                          initialValue: _email,
                          decoration: InputDecoration(
                            hintText: 'email',
                            labelText: 'email',
                          ),
                          style: TextStyle(color: Colors.white54),
                          enabled: false,
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'username',
                            labelText: 'username',
                          ),
                          validator: _validateUsername,
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'name',
                            labelText: 'name',
                          ),
                          validator: _validateName,
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _changePhoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetButton(
              onPressed: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.camera);
              },
              label: 'Camera',
              icon: Icons.camera_alt,
            ),
            _SheetButton(
              onPressed: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
              label: 'Gallery',
              icon: Icons.photo,
            ),
          ],
        );
      },
    );
  }

  Future _pickPhoto(ImageSource source) async {
    setState(() {
      _imageLoading = true;
    });
    var croppedImage;
    final image = await ImagePicker.pickImage(source: source);
    if (image == null) {
      print('aborted picking');
    } else {
      croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(
          ratioX: 1.0,
          ratioY: 1.0,
        ),
        maxWidth: 512,
        maxHeight: 512,
      );

      if (croppedImage == null) {
        print('aborted cropping');
      } else {
        try {
          _photoUrl = await _dbService.updatePhoto(croppedImage);
          _photo = null;
        } catch (e) {
          print(e);
          if (this.mounted) _snackIt('Something went wrong');
        }
      }
    }

    if (this.mounted) {
      _snackIt('Photo updated');
      setState(() {
        _imageLoading = false;
      });
    }
  }

  void _saveProfile() async {
    setState(() {
      _loading = true;
    });

    final Map<String, String> profile = {};

    final newUsername = _usernameController.value.text;
    if (_username != newUsername) {
      profile['username'] = newUsername;
    }

    final newName = _nameController.value.text;
    if (_name != newName) {
      profile['name'] = newName;
    }

    if (profile.isEmpty) {
      print('empty profile');
      Navigator.of(context).pop();
    } else {
      try {
        await _dbService.updateProfile(profile);
        Navigator.of(context).pop();
      } catch (e) {
        if (e is PlatformException) {
          if (e.code == 'ERROR_USERNAME_EXISTS') {
            _snackIt('username exists already');
          }
        } else {
          _snackIt('Something went wrong');
        }
      }
    }
    setState(() {
      _loading = false;
    });
  }

  void _snackIt(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _validateUsername(String username) {
    if (username.length <= 3) return 'Username too short';
    if (username.length > 20) return 'Username too long';
    if (!isAlphanumeric(username[0])) return 'must start with a letter/number';
    if (!isAlphanumeric(username[username.length - 1]))
      return 'must end with a letter/number';
    else if (dotsReg.hasMatch(username))
      return 'can\'t have more than one period in a row';
    else if (underScoresReg.hasMatch(username))
      return 'can\'t have more than one underscore in a row';
    if (!usernameReg.hasMatch(username)) {
      return 'contains invalid characters';
    }

    return null;
  }

  String _validateName(String name) {
    if (name.isEmpty) return 'can\'t be empty';
    if (name.length > 50) return 'Too long';
    if (!isAscii(name)) return 'contains invalid characters';
    return null;
  }

  bool _nothingChanged() {
    return _username == _usernameController.value.text &&
        _name == _nameController.value.text;
  }

  Future<bool> _onBackPressed() async {
    if (_nothingChanged()) return true;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titleTextStyle: TextStyle(
            fontSize: 20.0,
          ),
          contentTextStyle: TextStyle(
            fontSize: 16.0,
          ),
          backgroundColor: kPrimaryColorTran,
          title: Text('Warning'),
          content: SingleChildScrollView(
            child: Text(
              'You have some unsaved changes, are you sure you want to quit?',
            ),
          ),
          actions: [
            FlatButton(
              child: Text('yes'),
              textColor: kSecondaryColor,
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            FlatButton(
              child: Text('no'),
              textColor: kSecondaryColor,
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }
}

class _SheetButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function onPressed;

  const _SheetButton({this.icon, this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kSecondaryColor,
      child: InkWell(
        onTap: onPressed,
        splashColor: Colors.black45,
        highlightColor: Colors.black26,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon),
              SizedBox(
                width: 4.0,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
