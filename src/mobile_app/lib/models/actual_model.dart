// To parse this JSON data, do
//
//     final actual = actualFromJson(jsonString);

import 'dart:convert';

Actual actualFromJson(String str) => Actual.fromJson(json.decode(str));

String actualToJson(Actual data) => json.encode(data.toJson());

class Actual {
    bool rotation;
    String wifiStatus;
    double aHumidity;
    double aTemperature;
    Errors errors;
    double aPressure;

    Actual({
        required this.rotation,
        required this.aPressure,
        required this.errors,
        required this.aTemperature,
        required this.aHumidity,
        required this.wifiStatus,
    });

    factory Actual.fromJson(Map<String, dynamic> json) => Actual(
        rotation: json["rotation"],
        aPressure: double.parse(json["a_pressure"]),
        errors: Errors.fromJson(json["errors"]),
        aTemperature: double.parse(json["a_temperature"]),
        aHumidity: double.parse(json["a_humidity"]),
        wifiStatus: json["wifi_status"],
    );

    Map<String, dynamic> toJson() => {
        "rotation": rotation,
        "a_pressure": aPressure.toString(),
        "errors": errors.toJson(),
        "a_temperature": aTemperature.toString(),
        "a_humidity": aHumidity.toString(),
        "wifi_status": wifiStatus,
    };
}

class Errors {
    List<String> rotation;
    List<dynamic> temperature;
    List<String> sensors;
    List<dynamic> humidity;
    List<dynamic> wifi;

    Errors({
        required this.rotation,
        required this.temperature,
        required this.sensors,
        required this.humidity,
        required this.wifi,
    });

    factory Errors.fromJson(Map<String, dynamic> json) => Errors(
        rotation: List<String>.from(json["rotation"].map((x) => x)),
        temperature: List<dynamic>.from(json["temperature"].map((x) => x)),
        sensors: List<String>.from(json["sensors"].map((x) => x)),
        humidity: List<dynamic>.from(json["humidity"].map((x) => x)),
        wifi: List<dynamic>.from(json["wifi"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "rotation": List<dynamic>.from(rotation.map((x) => x)),
        "temperature": List<dynamic>.from(temperature.map((x) => x)),
        "sensors": List<dynamic>.from(sensors.map((x) => x)),
        "humidity": List<dynamic>.from(humidity.map((x) => x)),
        "wifi": List<dynamic>.from(wifi.map((x) => x)),
    };
}
