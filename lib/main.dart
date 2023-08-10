import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pands_app/screens/chat_screen.dart';
import 'package:pands_app/screens/login_page.dart';
import 'package:pands_app/screens/register_page.dart';



Future  main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(PandsApp());
}

class PandsApp extends StatelessWidget {
  Color _primaryColor = Color(0xffdc54fe);
  Color _accentColor = Color(0xff8A02AE);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute:  LoginPage.id,
      routes: {
        LoginPage.id : (context) => LoginPage(),
        RegisterPage.id:(context) => RegisterPage(),
        ChatScreen.id: (context) => ChatScreen(),
      },
    );
  }
}

