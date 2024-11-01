import 'dart:convert';

Config configFromJson(String str) => Config.fromJson(json.decode(str));

String configToJson(Config data) => json.encode(data.toJson());

class Config {
  String hash;
  double minTemperature;
  int minHum;
  String incubatorName;
  int maxHum;
  int rotationDuration;
  int trayThreeDate;
  double maxTemperature;
  int rotationPeriod;
  int trayTwoDate;
  int trayOneDate;
  int incubationPeriod;
  String? passwd;
  String? ssid;

  Config({
    required this.hash,
    required this.minTemperature,
    required this.minHum,
    required this.incubatorName,
    required this.maxHum,
    required this.rotationDuration,
    required this.trayThreeDate,
    required this.maxTemperature,
    required this.rotationPeriod,
    required this.trayTwoDate,
    required this.trayOneDate,
    required this.incubationPeriod,
    this.passwd,
    this.ssid,
  });

  factory Config.fromJson(Map<String, dynamic> json) => Config(
        hash: json["hash"],
        minTemperature: json["min_temperature"]?.toDouble() ??
            0.0, // fallback to 0.0 if null
        minHum: json["min_hum"] ?? 0, // fallback to 0 if null
        incubatorName: json["incubator_name"] ??
            "default_name", // fallback to default name
        maxHum: json["max_hum"] ?? 0, // fallback to 0 if null
        rotationDuration:
            json["rotation_duration"] ?? 0, // fallback to 0 if null
        trayThreeDate: json["tray_three_date"] ?? 0, // fallback to 0 if null
        maxTemperature: json["max_temperature"]?.toDouble() ??
            0.0, // fallback to 0.0 if null
        rotationPeriod: json["rotation_period"] ?? 0, // fallback to 0 if null
        trayTwoDate: json["tray_two_date"] ?? 0, // fallback to 0 if null
        trayOneDate: json["tray_one_date"] ?? 0, // fallback to 0 if null
        incubationPeriod:
            json["incubation_period"] ?? 0, // fallback to 0 if null
        passwd: json["passwd"] ?? "", // fallback to an empty string if null
        ssid: json["ssid"] ?? "", // fallback to an empty string if null
      );

  Map<String, dynamic> toJson() => {
        "hash": hash,
        "min_temperature": minTemperature,
        "min_hum": minHum,
        "incubator_name": incubatorName,
        "max_hum": maxHum,
        "rotation_duration": rotationDuration,
        "tray_three_date": trayThreeDate,
        "max_temperature": maxTemperature,
        "rotation_period": rotationPeriod,
        "tray_two_date": trayTwoDate,
        "tray_one_date": trayOneDate,
        "incubation_period": incubationPeriod,
        "passwd": passwd,
        "ssid": ssid,
      };
}
