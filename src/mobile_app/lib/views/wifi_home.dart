import 'package:incubapp_lite/models/wifi_model.dart';
import 'package:incubapp_lite/models/actual_model.dart';
import 'package:incubapp_lite/models/config_model.dart';
import 'package:incubapp_lite/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:incubapp_lite/views/initial_home.dart';
import 'package:incubapp_lite/views/home.dart';
import 'package:incubapp_lite/views/counter_home.dart';
import 'package:incubapp_lite/views/graf_home.dart';

class WHome extends StatefulWidget {
  const WHome({Key? key}) : super(key: key);

  @override
  _WHomeState createState() => _WHomeState();
}

class _WHomeState extends State<WHome> {
  int _selectedIndex = 0;
  late Wifi? _wifiModel = null;
  late Config? _configModel = Config(
      incubatorName: "Nombre",
      ssid: "SSID",
      minHum: 50,
      maxHum: 70,
      minTemperature: 37,
      maxTemperature: 39,
      rotationPeriod: 3600000,
      rotationDuration: 5000,
      passwd: "12345678",
      hash: "1234",
      incubationPeriod: 18,
      trayOneDate: 10000,
      trayTwoDate: 5000,
      trayThreeDate: 0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _wifiModel = await ApiService().getWifi();
    _configModel = await ApiService().getConfig();
    setState(() {});
  }

  Future<void> _connectToWifi(String ssid, String password) async {
    try {
      if (ssid.isEmpty) {
        throw ("La SSID no puede estar vacía");
      }

      // Construimos el JSON actualizado
      Map<String, dynamic> updatedConfig = {
        'ssid': ssid,
        'passwd': password,
        'hash': _configModel?.hash,
        'incubator_name': _configModel?.incubatorName,
        'incubation_period': _configModel?.incubationPeriod,
        'max_temperature': _configModel?.maxTemperature,
        'min_temperature': _configModel?.minTemperature,
        'max_hum': _configModel?.maxHum,
        'min_hum': _configModel?.minHum,
        'rotation_duration': _configModel?.rotationDuration,
        'rotation_period': _configModel?.rotationPeriod,
        'tray_one_date': _configModel?.trayOneDate,
        'tray_two_date': _configModel?.trayTwoDate,
        'tray_three_date': _configModel?.trayThreeDate,
      };

      // Enviamos el JSON a la API
      await ApiService().updateConfig(updatedConfig);

      showDialog(
        context: context,
        barrierDismissible: false, // Evita que el usuario cierre el diálogo
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Conectando...'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Esperando respuesta del dispositivo.'),
              ],
            ),
          );
        },
      );

      // Espera para comprobar el estado de conexión
      const delayDuration = Duration(seconds: 15);
      await Future.delayed(delayDuration);

      // Cerrar el diálogo de carga
      Navigator.pop(context);

      // Después de enviar el JSON, verificamos el estado de la conexión
      Actual? actualStatus = await ApiService().getActual();
      
      String message;
      if (actualStatus?.wifiStatus == "connected") {
        message = "Contraseña correcta. Conexión exitosa.";
      } else if (actualStatus?.wifiStatus == "disconnected") {
        message = "No se pudo conectar a la red. Verifique las credenciales.";
      } else {
        message = "Verifique la Conexión";
      }

      // Mostramos un mensaje al usuario
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Resultado de la conexión"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Aceptar"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Error: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("No se pudo conectar: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Aceptar"),
            ),
          ],
        ),
      );
    }
  }



  Future<void> _showPasswordDialog(String ssid) async {
    String password = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ingrese la contraseña para $ssid'),
          content: TextField(
            onChanged: (value) {
              password = value;
            },
            obscureText: true,
            decoration: InputDecoration(labelText: 'Contraseña'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _connectToWifi(ssid, password);
              },
              child: Text('Conectar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REDES DISPONIBLES'),
      ),

      body: _wifiModel == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _wifiModel!.networks.length,
              itemBuilder: (context, index) {
                final network = _wifiModel!.networks[index];
                return Card(
                  child: ListTile(
                    title: Text(network.ssid),
                    subtitle: Text('RSSI: ${network.rssi}'),
                    onTap: () {
                      // Al seleccionar una red, mostrar el diálogo de contraseña
                      _showPasswordDialog(network.ssid);
                    },
                  ),
                );
              },
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
        // Navigator.push(context, MaterialPageRoute(builder: (context) => WHome()));
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
