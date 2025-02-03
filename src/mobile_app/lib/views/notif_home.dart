import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:incubapp_lite/services/api_services.dart';
import 'package:incubapp_lite/models/actual_model.dart';

class NHome extends StatefulWidget {
  @override
  _NHomeState createState() => _NHomeState();
}

class _NHomeState extends State<NHome> {
  Actual? _actualModel;
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color.fromRGBO(65, 65, 65, 1),
      body: _actualModel == null
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
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_actualModel!.errors.rotation.isNotEmpty)
                    _buildErrorSection(
                      'Errores de Rotación',
                      _actualModel!.errors.rotation,
                      Icons.sync_problem,
                    ),
                  if (_actualModel!.errors.temperature.isNotEmpty)
                    _buildErrorSection(
                      'Errores de Temperatura',
                      _actualModel!.errors.temperature,
                      Icons.thermostat_outlined,
                    ),
                  if (_actualModel!.errors.humidity.isNotEmpty)
                    _buildErrorSection(
                      'Errores de Humedad',
                      _actualModel!.errors.humidity,
                      Icons.water_drop_outlined,
                    ),
                  if (_actualModel!.errors.sensors.isNotEmpty)
                    _buildErrorSection(
                      'Errores de Sensores',
                      _actualModel!.errors.sensors,
                      Icons.sensors,
                    ),
                  if (_actualModel!.errors.wifi.isNotEmpty)
                    _buildErrorSection(
                      'Errores de WiFi',
                      _actualModel!.errors.wifi,
                      Icons.wifi_off,
                    ),
                  if (_noErrors)
                    Center(
                      child: Text(
                        'No se encuentran errores',
                        style: GoogleFonts.questrial(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
    );
  }

  bool get _noErrors => 
    _actualModel != null &&
    _actualModel!.errors.rotation.isEmpty &&
    _actualModel!.errors.temperature.isEmpty &&
    _actualModel!.errors.humidity.isEmpty &&
    _actualModel!.errors.sensors.isEmpty &&
    _actualModel!.errors.wifi.isEmpty;

  Widget _buildErrorSection(String title, List<dynamic> errors, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(225, 255, 255, 255),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.questrial(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...errors.map((error) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    error.toString(),
                    style: GoogleFonts.questrial(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}