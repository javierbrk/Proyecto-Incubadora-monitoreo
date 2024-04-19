import 'package:incubapp_lite/services/api_services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:incubapp_lite/views/initial_home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:incubapp_lite/views/home.dart';
import 'package:incubapp_lite/views/wifi_home.dart';
import 'package:incubapp_lite/views/initial_home.dart';
import 'package:incubapp_lite/services/api_services.dart';
import 'package:incubapp_lite/views/counter_home.dart';
import 'package:incubapp_lite/views/graf_home.dart';
import 'package:incubapp_lite/models/config_model.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  int _selectedIndex = 0; 

  late Config? _configModel = Config(ssid: "SSID", minTemperature: 37, maxTemperature: 39, rotationPeriod: 3600000, rotationDuration: 5000, passwd: "12345678", hash: 1234, incubationPeriod: 18, trayOneDate: 10000, trayTwoDate: 5000, trayThreeDate: 0);
  @override
  void initState() {
    super.initState();
    _getData();
  }
  Future<void> _getData() async {
    _configModel = await ApiService().getConfig();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    
    int hash = _configModel?.hash ?? 0;
    int incubation_period = _configModel?.incubationPeriod ?? 0;
    int maxtemp = _configModel?.maxTemperature ?? 0;
    int mintemp = _configModel?.minTemperature ?? 0;
    String password = _configModel?.passwd ?? "";
    int rotation_duration = _configModel?.rotationDuration ?? 0;
    int rotation_period =_configModel?.rotationPeriod ?? 0;
    String ssid = _configModel?.ssid ?? "";
    int tray_one_date = _configModel?.trayOneDate ?? 0;
    int tray_two_date = _configModel?.trayTwoDate ?? 0;
    int tray_three_date = _configModel?.trayThreeDate ?? 0;
    
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuraciones'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: Text('NOMBRE DE LA INCUBADORA'),
              subtitle: Text('Incu 1'),
            ),
            ListTile(
              title: Text('TEMPERATURA MÁXIMA'),
              subtitle: Text('$maxtemp'),
            ),
            ListTile(
              title: Text('TEMPERATURA MÍNIMA'),
              subtitle: Text('$mintemp'),
            ),
            ListTile(
              title: Text('DIAS DE INCUBACION B. 1'),
              subtitle: Text('$tray_one_date'),
            ),
            ListTile(
              title: Text('DIAS DE INCUBACION B. 2'),
              subtitle: Text('$tray_two_date'),
            ),
            ListTile(
              title: Text('DIAS DE INCUBACION B. 3'),
              subtitle: Text('$tray_three_date'),
            ),
            ListTile(
              title: Text('DÍAS DEL PROCESO'),
              subtitle: Text('$incubation_period'),
            ),
            ListTile(
              title: Text('HASH NOTIFY'),
              subtitle: Text('$hash'),
            ),
          ],
        ),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color.fromARGB(65, 65, 65, 1),
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.black,
        items: [
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
        // Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => CHome()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => GHome()));
        break;
    }
  }
}
