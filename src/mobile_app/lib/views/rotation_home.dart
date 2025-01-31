import 'package:incubapp_lite/models/wifi_model.dart';
import 'package:incubapp_lite/models/actual_model.dart';
import 'package:incubapp_lite/models/config_model.dart';
import 'package:incubapp_lite/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:incubapp_lite/views/initial_home.dart';
import 'package:incubapp_lite/views/home.dart';
import 'package:incubapp_lite/views/counter_home.dart';
import 'package:incubapp_lite/views/graf_home.dart';
import 'package:incubapp_lite/views/wifi_home.dart';


class RHome extends StatefulWidget {
  @override
  _RHomeState createState() => _RHomeState();
}

class _RHomeState extends State<RHome> {

  int _selectedIndex = 0;
  
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rotación'),
      ),
      backgroundColor: const Color.fromRGBO(65, 65, 65, 1),
      body: Center(
        child: Text(
          'mimimi',
          style: GoogleFonts.questrial(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color.fromARGB(65, 65, 65, 1),
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wifi),
            label: 'Conexion',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuraciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.egg),
            label: 'Contador',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_backup_restore),
            label: 'Rotación',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart),
            label: 'Grafana',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => IHome()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => WHome()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => CHome()));
        break;
      case 4:
        break;
      case 5:
        Navigator.push(context, MaterialPageRoute(builder: (context) => GHome()));
        break;
    }
  }

}