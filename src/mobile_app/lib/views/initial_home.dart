import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:incubapp_lite/models/actual_model.dart';
import 'package:incubapp_lite/views/home.dart';
import 'package:incubapp_lite/views/wifi_home.dart';
import 'package:incubapp_lite/services/api_services.dart';
import 'package:incubapp_lite/views/counter_home.dart';
import 'package:incubapp_lite/views/graf_home.dart';
import 'package:incubapp_lite/views/notif_home.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IHome(),
    ));

class IHome extends StatefulWidget {
  @override
  _IHomeState createState() => _IHomeState();
}

class _IHomeState extends State<IHome> {
  Actual? _actualModel;
  int _selectedIndex = 0;
  bool _showConnectionError = false;
  
  @override
  void initState() {
    super.initState();
    _getData();
    _startConnectionTimer();
  }

  void _startConnectionTimer() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_actualModel == null && mounted) {
        setState(() {
          _showConnectionError = true;
        });
      }
    });
  }
  
  Future<void> _getData() async {
    _actualModel = await ApiService().getActual();
    setState(() {});
  }

  void _retryConnection() {
    setState(() {
      _showConnectionError = false;
    });
    _getData();
    _startConnectionTimer();
  }
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    if (_actualModel == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              iconSize: 30.0,
              icon: const Icon(Icons.notifications, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NHome()),
                );
              },
            ),
          ],
        ),
        backgroundColor: const Color.fromRGBO(65, 65, 65, 1),
        body: Center(
          child: _showConnectionError 
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Verifique conexión con incubadora',
                    style: GoogleFonts.questrial(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _retryConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              )
            : const CircularProgressIndicator(
                color: Colors.white,
              ),
        ),
        bottomNavigationBar: _buildNavigationBar(),
      );
    }

    final temperature = _actualModel!.aTemperature;
    final humidity = _actualModel!.aHumidity;
    final wifiStatus = _actualModel!.wifiStatus;
    final rotation = _actualModel!.rotation;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            iconSize: 30.0,
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NHome()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey,
      body: _buildBody(size, temperature, humidity, wifiStatus, rotation),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildNavigationBar() {
    return BottomNavigationBar(
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
          icon: Icon(Icons.monitor_heart),
          label: 'Grafana',
        ),
      ],
    );
  }

  Widget _buildBody(Size size, double temperature, double humidity, String wifiStatus, bool rotation) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.fromRGBO(65, 65, 65, 1), Color.fromRGBO(65, 65, 65, 1)]
            )
          ),
          child: SingleChildScrollView( 
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30.0),
                  buildWifiStatus(context, wifiStatus, size),
                  const SizedBox(height: 30.0),
                  buildRotStatus(context, rotation, size),
                  const SizedBox(height: 30.0),
                  const Icon(
                    FontAwesomeIcons.temperatureHalf,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 40.0,
                  ),
                  SizedBox(height: size.height * 0.03),
                  temperatureTitle(size),
                  const SizedBox(height: 30.0),
                  temperatureValue(size, temperature),
                  const SizedBox(height: 30.0),
                  const Icon(
                    FontAwesomeIcons.droplet,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 40.0,
                  ),
                  const SizedBox(height: 10.0),
                  humidityTitle(size),
                  SizedBox(height: size.height * 0.05),
                  humidityValue(size, humidity),
                  const SizedBox(height: 30.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildWifiStatus(BuildContext context, String wifiStatus, Size size) {
    late final Color statusColor;
    late final String displayText;
    
    switch (wifiStatus) {
      case "connected":
        statusColor = Colors.lightGreenAccent;
        displayText = "Conectado";
        break;
      case "disconnected":
        statusColor = Colors.red;
        displayText = "Desconectado";
        break;
      default:
        statusColor = Colors.orange;
        displayText = "";
        
        // Solo mostramos el diálogo si no es un estado conocido
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(seconds: 4), () {
            if (context.mounted && 
                wifiStatus != "connected" && 
                wifiStatus != "disconnected") {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Estado de Conexión'),
                    content: const Text('No se ha podido establecer conexión con la incubadora.'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Aceptar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          });
        });
        break;
    }

    return Text(
      displayText,
      style: GoogleFonts.questrial(
        color: statusColor,
        fontSize: size.height * 0.03,
      ),
    );
  }

  Widget buildRotStatus(BuildContext context, bool rotation, Size size) {
    Color statusColor = rotation 
        ? Colors.lightGreenAccent
        : Colors.red;
    
    return Text(
      rotation
          ? "Rotación Activa"
          : "Error de Rotación",
      style: GoogleFonts.questrial(
        color: statusColor,
        fontSize: size.height * 0.03,
      ),
    );
}

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // Navegar a la pantalla de inicio
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
        Navigator.push(context, MaterialPageRoute(builder: (context) => GHome()));
        break;
    }
  }
}

Widget temperatureTitle(size) {
  return Text(
    "Temperatura:",
    style: GoogleFonts.questrial(
      color: const Color.fromARGB(255, 255, 255, 255),
      fontSize: size.height * 0.05
    )
  );
}

Widget temperatureValue(size, temperature) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(
      '$temperature˚C',
      style: GoogleFonts.questrial(
        color: Tcolor(temperature),
        fontSize: size.height * 0.13,
      ),
    ),
  );
}

Color Tcolor(temperature) {
  if (temperature <= 0) {
    return Colors.yellow;
  } else if (temperature <= 38 && temperature >= 36.5) {
    return Colors.lightGreenAccent;
  } else {
    return Colors.red;
  }
}

Color Hcolor(humidity) {
  if (humidity <= 0) {
    return Colors.red;
  } else if (humidity <= 70.0 && humidity >= 55.0) {
    return Colors.lightGreenAccent;
  } else {
    return Colors.red;
  }
}

Widget humidityTitle(size) {
  return Text(
    "Humedad:",
    style: GoogleFonts.questrial(
      color: const Color.fromARGB(255, 255, 255, 255),
      fontSize: size.height * 0.05
    )
  );
}

Widget humidityValue(size, humidity) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(
      '$humidity %',
      style: GoogleFonts.questrial(
        color: Hcolor(humidity),
        fontSize: size.height * 0.13,
      ),
    ),
  );
}