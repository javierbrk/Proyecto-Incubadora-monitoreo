import 'dart:io';                     
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:incubapp_lite/views/initial_home.dart';
import 'package:incubapp_lite/utils/constants.dart';


class NHome extends StatefulWidget {
  @override
  _NHomeState createState() => _NHomeState();
}

class _NHomeState extends State<NHome> {

  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
      ),
      body: Center(
        child: Text(
          'mimimi',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}