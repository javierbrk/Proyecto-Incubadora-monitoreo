import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:incubapp_lite/models/actual_model.dart';
import 'package:incubapp_lite/utils/constants.dart';
import 'package:incubapp_lite/models/wifi_model.dart';
import 'package:incubapp_lite/models/config_model.dart';

// logica para consumo de datos en la api

class ApiService {
  
  Future<Wifi?> getWifi() async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.wifiEndPoint);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        Wifi model = wifiFromJson(response.body);
        return model;
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  Future<void> sendRotation(String direction) async {
    try {
      final url = ApiConstants.baseUrl + ApiConstants.rotationEndPoint;
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'move': direction
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Error al enviar comando de rotación');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<Actual?> getActual() async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.actualEndPoint);
      print('URL de la API: $url');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        Actual model = actualFromJson(response.body);
        return model;
      } else {
        print('Respuesta de la API no exitosa: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la llamada a la API: $e');
      log(e.toString());
    }
    return null;
  }

  Future<Config?> getConfig() async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.configEndPoint);
      print('URL de la API: $url');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        Config model = configFromJson(response.body);
        return model;
      } else {
        print('Respuesta de la API no exitosa: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la llamada a la API: $e');
      log(e.toString());
    }
    return null;
  }

  Future<Config?> updateConfig(Map<String, dynamic> updatedData) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.configEndPoint);
      print('URL de la API: $url');

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedData),
      );

      print(jsonEncode(updatedData));
      if (response.statusCode == 200) {
        print('Datos actualizados correctamente en la API');
        return configFromJson(response.body);
      } else {
        print('Respuesta de la API no exitosa: ${response.statusCode}');
        print('${response.body}');
      }
    } catch (e) {
      print('Error en la llamada a la API: $e');
    }
    return null;
  }

  Future<void> subscribeToNtfyChannelFromConfig(String topic) async {
    try {
      print("Intentando suscribirse al canal: $topic");
      var url = Uri.parse("https://ntfy.sh/$topic");
      var request = http.Request("GET", url);
      var response = await request.send();

      if (response.statusCode == 200) {
        response.stream.transform(utf8.decoder).listen((data) {
          print("Notificación recibida: $data");
        });
      } else {
        print("Error al suscribirse al canal: ${response.statusCode}");
      }
    } catch (e) {
      print("Excepción al suscribirse: $e");
    }
  }
}
