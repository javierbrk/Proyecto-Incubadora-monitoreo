import 'package:incubapp_lite/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:incubapp_lite/views/initial_home.dart';
import 'package:incubapp_lite/views/home.dart';
import 'package:incubapp_lite/views/counter_home.dart';
import 'package:incubapp_lite/views/graf_home.dart';
import 'package:incubapp_lite/views/wifi_home.dart';
import 'package:google_fonts/google_fonts.dart';

class RHome extends StatefulWidget {
  @override
  _RHomeState createState() => _RHomeState();
}

class _RHomeState extends State<RHome> {
  int _selectedIndex = 0;
  bool _showConnectionError = false;
  bool _isConnected = false;
  DateTime? _lastRotationCommand; // Variable para trackear el último comando
  final _throttleDuration = const Duration(seconds: 1); // Duración del throttle

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _startConnectionTimer();
  }

  void _startConnectionTimer() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isConnected && mounted) {
        setState(() {
          _showConnectionError = true;
        });
      }
    });
  }

  Future<void> _checkConnection() async {
    try {
      final actualStatus = await ApiService().getActual();
      if (mounted) {
        setState(() {
          _isConnected = true;
          _showConnectionError = false;
        });
      }
    } catch (e) {
      print(e);
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
    }
  }

  void _retryConnection() {
    setState(() {
      _showConnectionError = false;
      _isConnected = false;
    });
    _checkConnection();
    _startConnectionTimer();
  }

  // Método para verificar si podemos enviar un nuevo comando
  bool _canSendRotationCommand() {
    if (_lastRotationCommand == null) return true;
    return DateTime.now().difference(_lastRotationCommand!) >= _throttleDuration;
  }

  // Método para enviar comando de rotación con throttling
  Future<void> _sendRotationCommand(String direction) async {
    if (!_canSendRotationCommand()) {
      print("Comando ignorado: muy pronto desde el último comando");
      return;
    }

    try {
      await ApiService().sendRotation(direction);
      _lastRotationCommand = DateTime.now();
      print("Comando de rotación hacia $direction enviado");
    } catch (e) {
      print("Error al enviar comando: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotación'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color.fromRGBO(65, 65, 65, 1),
      body: !_isConnected
          ? Center(
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
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _sendRotationCommand('up'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      backgroundColor: Colors.white70,
                    ),
                    child: const Icon(
                      Icons.arrow_drop_up,
                      color: Colors.black54,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => _sendRotationCommand('down'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      backgroundColor: Colors.white70,
                    ),
                    child: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black54,
                      size: 50,
                    ),
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