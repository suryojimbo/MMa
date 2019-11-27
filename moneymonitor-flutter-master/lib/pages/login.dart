import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:money_monitor/scoped_models/main.dart';
import 'package:money_monitor/main.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showSignUp = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _resetFormKey = GlobalKey<FormState>();
  String _resetFormData = "";
  final Map<String, String> _formData = {
    "email": null,
    "password": null,
    "confirmPassword": null
  };

  void _authenticateWithGoogle() async {
    await GoogleSignIn().signOut();
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    // TODO Replace with AuthCredential Login once packages updated
    await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  void _authenticateWithEmailandPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
    } catch (e) {
      String errorMessage = e.message;
      print(errorMessage);
      String invalidPassword =
          "Kata sandi salah";
      String userDoesntExist =
          "Akun tidak ditemukan, silahkan daftar akun baru";

      if (errorMessage == invalidPassword) {
        _buildSignInErrorDialog("Kata sandi salah", true);
      } else if (errorMessage == userDoesntExist) {
        _buildSignInErrorDialog("Akun tidak ditemukan", true);
      } else {
        _buildSignInErrorDialog(
            "Tidak bisa masuk saat. Coba lagi nanti", true);
      }
    }
  }

  void _signUpWithEmailandPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      setState(() {
        _showSignUp = false;
      });
    } catch (e) {
      String errorMessage = e.message;
      print(errorMessage);
      if (errorMessage ==
          "Email sudah digunakan akun lain.") {
        _buildSignInErrorDialog(
            "Email sudah digunakan akun lain.");
      } else {
        _buildSignInErrorDialog(
            "Tidak bisa daftar saat ini, coba lagi nanti", true);
      }
    }
  }

  _buildSignInErrorDialog(String message, [bool showReset]) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          title: Text("Akun Error"),
          actions: <Widget>[
            showReset != null && showReset == true
                ? MaterialButton(
                    child: Text("Reset Kata Sandi"),
                    onPressed: () {},
                  )
                : Container(),
            MaterialButton(
              child: Text("Ok"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Text(
      "Money Manager",
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 40.0,
        fontWeight: FontWeight.w700,
        color: Colors.yellow[700],
        wordSpacing: 2.0
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return "Mohon isi dengan alamat email yang valid.";
        }
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 20.0,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(30.0),
        ),
        hintText: "Email",
        hintStyle: TextStyle(
          fontWeight: FontWeight.w600,
           fontFamily: 'Poppins',
           color: Colors.grey[500]
        ),
        filled: true,
        fillColor: deviceTheme == "light" ? Colors.white : Colors.grey[600],
      ),
      onSaved: (String value) {
        _formData["email"] = value;
      },
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      validator: (String value) {
        if (value.isEmpty || value.length < 8) {
          return "Kata sandi harus lebih dari 8 karakter";
        }
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 20.0,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(30.0),
        ),
        helperText: _showSignUp ? "Minimal 8 karakter" : "",
        hintText: "Kata sandi",
        hintStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          color: Colors.grey[500]
        ),
        hasFloatingPlaceholder: true,
        filled: true,
        fillColor: deviceTheme == "light" ? Colors.white : Colors.grey[600],
      ),
      onSaved: (String value) {
        _formData["password"] = value;
      },
      obscureText: true,
    );
  }

  Widget _buildConfirmPassword() {
    return Column(
      children: <Widget>[
        TextFormField(
          validator: (String value) {
            if (value.isEmpty || value.length < 8) {
              return "Kata sandi minimal 8 karakter.";
            }
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(30.0),
            ),
            hintText: "Ketik ulang kata sandi",
            hintStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Colors.grey[500]
            ),
            hasFloatingPlaceholder: true,
            filled: true,
            fillColor: deviceTheme == "light" ? Colors.white : Colors.grey[600],
          ),
          onSaved: (String value) {
            _formData["confirmPassword"] = value;
          },
          obscureText: true,
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: deviceTheme == "light"
            ? Colors.yellow[700]
            : Colors.yellow[700],
      ),
      child: MaterialButton(
        onPressed: () async {
          if (!_resetFormKey.currentState.validate()) {
            return "";
          }
          _resetFormKey.currentState.save();
          await FirebaseAuth.instance
              .sendPasswordResetEmail(email: _resetFormData);
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Reset Password", style: TextStyle(fontFamily: 'Poppins')),
                content: Text(
                    "If an account exists with the email provided a reset link will be sent to that email.", style: TextStyle(fontFamily: 'Poppins')),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Okay"),
                  ),
                ],
              );
            },
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.send,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "Send",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildCancelButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: deviceTheme == "light"
            ? Colors.yellow[700]
            : Colors.yellow[700],
      ),
      child: MaterialButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.cancel,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "Cancel",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildResetDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        height: 200,
        width: 500,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Text(
              "Reset Password",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 10,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Card(
              clipBehavior: Clip.none,
              elevation: 3.0,
              margin: EdgeInsets.symmetric(
                horizontal: 10.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Form(
                key: _resetFormKey,
                child: TextFormField(
                  onSaved: (String value) => _resetFormData = value,
                  validator: (String value) {
                    if (value.isEmpty ||
                        !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                            .hasMatch(value)) {
                      return "Please enter a valid email address.";
                    }
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 15.0,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    hintText: "Email",
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                    hasFloatingPlaceholder: true,
                    prefix: Text("  "),
                    filled: true,
                    fillColor: deviceTheme == "light"
                        ? Colors.white
                        : Colors.grey[600],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildSaveButton(),
                SizedBox(
                  width: 10,
                ),
                _buildCancelButton()
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetWidth = MediaQuery.of(context).size.width > 550.0
        ? 500.0
        : MediaQuery.of(context).size.width * 0.9;

    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget widget, MainModel model) {
        return Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: deviceTheme == "light"
                ? Colors.yellow[700]
                : Colors.yellow[700],
            elevation: 4.0,
            icon: const Icon(MdiIcons.google, color: Colors.white),
            label: const Text(
              'Masuk dengan akun Google', style: TextStyle(fontFamily: 'Poppins', color: Colors.white,)),
            onPressed: _authenticateWithGoogle,
          ),
          bottomNavigationBar: BottomAppBar(
            color: deviceTheme == "light" ? Colors.white : Colors.grey[700],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 80.0),
                    ),
                    IconButton(
                      icon:
                          Icon(_showSignUp ? MdiIcons.login : Icons.person_add),
                      onPressed: () {
                        setState(() {
                          _showSignUp = !_showSignUp;
                          _formData["email"] = null;
                          _formData["password"] = null;
                          _formData["confirmPassword"] = null;
                          _formKey.currentState.reset();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Container(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: targetWidth,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        _buildHeader(),
                        SizedBox(
                          height: 10.0,
                        ),
                        _buildEmailField(),
                        SizedBox(
                          height: 10,
                        ),
                        _buildPasswordField(),
                        SizedBox(
                          height: 10,
                        ),
                        _showSignUp ? _buildConfirmPassword() : Container(),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: deviceTheme == "light"
                                ? Colors.yellow[700]
                                : Colors.yellow[700],
                          ),
                          child: MaterialButton(
                            onPressed: () {
                              if (!_formKey.currentState.validate()) {
                                return "";
                              }

                              _formKey.currentState.save();

                              if (_showSignUp) {
                                if (_formData['password'] !=
                                    _formData['confirmPassword']) {
                                  return _buildSignInErrorDialog(
                                      "Kata sandi harus sama");
                                }
                                _signUpWithEmailandPassword(
                                    _formData["email"], _formData["password"]);
                              } else {
                                _authenticateWithEmailandPassword(
                                    _formData["email"], _formData["password"]);
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Text(
                                  _showSignUp ? "Daftar" : "Masuk",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                      ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 20.0),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // FlatButton(
                        //   child: Text(
                        //     "Reset Password",
                        //     style: TextStyle(
                        //       fontFamily: 'Poppins',
                        //       color: Colors.grey[500],
                        //     ),
                        //   ),
                        //   onPressed: () {
                        //     showDialog(
                        //       context: context,
                        //       builder: (context) => _buildResetDialog(),
                        //     );
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
