import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pands_app/screens/header_widget.dart';
import 'package:pands_app/screens/register_page.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pands_app/screens/theme_helper.dart';

import '../customSnackBar.dart';
import 'chat_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  static String id = "Login Page";

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double _headerHeight = 250;
  Key _formKey = GlobalKey<FormState>();
  bool showSpinner = false;
  late String email;
  late String password;
  TextEditingController _textFieldController1 = TextEditingController();
  TextEditingController _textFieldController2 = TextEditingController();
  FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textFieldController1.dispose();
    _textFieldController2.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Column(
          children: [
            Container(
              height: _headerHeight,
              child: HeaderWidget(
                  _headerHeight, true), //let's create a common header widget
            ),
            SafeArea(
              child: Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                  // This will be the login form
                  child: Column(
                    children: <Widget>[
                      TypewriterAnimatedTextKit(

                        speed: Duration(milliseconds: 200),
                        text: ['PandsApp'],
                        textStyle: TextStyle(
                            fontFamily: 'DancingScript',
                            fontSize: 70,
                            fontWeight: FontWeight.bold,
                            color:Colors.black),
                      ),
                      Text(
                        'Signin into your account',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 30.0),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                child: TextField(

                                  controller: _textFieldController1,
                                  onChanged: (value) {
                                    //Do something with the user input.
                                    email = value;
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: ThemeHelper().textInputDecoration(
                                      'E-mail', 'Enter your e-mail'),
                                ),
                                decoration:
                                    ThemeHelper().inputBoxDecorationShaddow(),
                              ),
                              SizedBox(height: 30.0),
                              Container(
                                child: TextField(
                                  focusNode: _focusNode,
                                  controller: _textFieldController2,
                                  onChanged: (value) {
                                    //Do something with the user input.
                                    password = value;
                                  },
                                  obscureText: true,
                                  decoration: ThemeHelper().textInputDecoration(
                                      'Password', 'Enter your password'),
                                ),
                                decoration:
                                    ThemeHelper().inputBoxDecorationShaddow(),
                              ),
                              SizedBox(height: 15.0),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
                                alignment: Alignment.topRight,
                              ),
                              Container(
                                decoration:
                                    ThemeHelper().buttonBoxDecoration(context),
                                child: ElevatedButton(
                                  style: ThemeHelper().buttonStyle(),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(40, 10, 40, 10),
                                    child: Text(
                                      'Sign In'.toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  onPressed: () async {

                                    setState(() {
                                      showSpinner = true;
                                    });
                                    final _auth = FirebaseAuth.instance;
                                    try {
                                      final checkUser = await _auth.signInWithEmailAndPassword(
                                          email: email, password: password);

                                      if (checkUser != null) {
                                        showSpinner = false;
                                        _focusNode.unfocus();
                                        _textFieldController1.clear();
                                        _textFieldController2.clear();
                                        MySnackbar.showAwesomeSnackbar(
                                          context,
                                          title: 'Success',
                                          message: 'Login successful.',

                                          contentType: ContentType.success,
                                        );
                                        Future.delayed(Duration(seconds: 2),(){
                                          Navigator.pushNamed(context, ChatScreen.id);
                                        });
                                        email = "";
                                        password = "";
                                      }

                                      setState(() {
                                        showSpinner = false;
                                      });
                                    } catch (e) {
                                      print(e);
                                      setState(() {
                                        showSpinner = false;
                                      });
                                    }

                                    //After successful login we will redirect to profile page. Let's create profile page now
                                  },
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
                                //child: Text('Don\'t have an account? Create'),
                                child: Text.rich(TextSpan(children: [
                                  TextSpan(text: "Don\'t have an account? "),
                                  TextSpan(
                                    text: 'Create',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: RegisterPage()));

                                      },
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                ])),
                              ),
                            ],
                          )),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
