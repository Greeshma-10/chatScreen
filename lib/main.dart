import 'dart:io';
import 'package:chatscreen/pages/registerScreen.dart';
import 'package:chatscreen/services/functions.dart';
import 'package:chatscreen/pages/homepage.dart';
import 'package:chatscreen/pages/loginpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid?
  await Firebase.initializeApp(
    options: const FirebaseOptions(apiKey: "AIzaSyCMkdWzbng2nOKHvCnUqBPx_sbwB_cJcWE", 
    appId:"1:905268420062:android:7701de12094accc09f914f",
     messagingSenderId: "905268420062",
      projectId:"chatscreen-a193d"),
  )
  :await Firebase.initializeApp();

  runApp( const MyApp());
}

class MyApp extends StatefulWidget {
  

  const MyApp({super.key});

  @override

  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn =false;
  @override
  void initState(){
    super.initState();
    getUserLoggedInStatus();
  }
  getUserLoggedInStatus()async{
    await functions.getUserLoggedInStatus().then((value){
      if (value!=null){
       setState(() {
         _isSignedIn=value;
       });
      }

    });
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "LoginPage":(context) => LoginPage(),

      },
      home:_isSignedIn? homepage():registerScreen()
    );
  }
}