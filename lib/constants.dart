import 'package:flutter/material.dart';

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  border: InputBorder.none,
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
  hintText: 'Type your message here...',
  hintStyle: TextStyle(
    fontSize: 18,
  ),


);

const kMessageContainerDecoration = BoxDecoration(
  //color: Colors.white,

  border: Border(

    top: BorderSide(color: Colors.black, width: 2.0),

  ),


);


const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',

  hintStyle: TextStyle(
    color: Colors.white,
  ),

  contentPadding:
  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);