import 'dart:convert';

Config configFromJson(String str) => Config.fromJson(json.decode(str));

String configToJson(Config data) => json.encode(data.toJson());

class Config {
    int hash;
    int incubationPeriod;
    String incubatorName;
    int maxHumidity;
    int maxTemperature;
    int minHumidity;
    int minTemperature;
    String passwd;
    int rotationDuration;
    int rotationPeriod;
    String ssid;
    int trayOneDate;
    int trayThreeDate;
    int trayTwoDate;

    Config({
        required this.hash,
        required this.incubationPeriod,
        required this.incubatorName,
        required this.maxHumidity,
        required this.maxTemperature,
        required this.minHumidity,
        required this.minTemperature,
        required this.passwd,
        required this.rotationDuration,
        required this.rotationPeriod,
        required this.ssid,
        required this.trayOneDate,
        required this.trayThreeDate,
        required this.trayTwoDate,
    });

    factory Config.fromJson(Map<String, dynamic> json) => Config(
        hash: json["hash"],
        incubationPeriod: json["incubation_period"],
        incubatorName: json["incubator_name"],
        maxHumidity: json["max_humidity"],
        maxTemperature: json["max_temperature"],
        minHumidity: json["min_humidity"],
        minTemperature: json["min_temperature"],
        passwd: json["passwd"],
        rotationDuration: json["rotation_duration"],
        rotationPeriod: json["rotation_period"],
        ssid: json["ssid"],
        trayOneDate: json["tray_one_date"],
        trayThreeDate: json["tray_three_date"],
        trayTwoDate: json["tray_two_date"],
    );

    Map<String, dynamic> toJson() => {
        "hash": hash,
        "incubation_period": incubationPeriod,
        "incubator_name": incubatorName,
        "max_humidity": maxHumidity,
        "max_temperature": maxTemperature,
        "min_humidity": minHumidity,
        "min_temperature": minTemperature,
        "passwd": passwd,
        "rotation_duration": rotationDuration,
        "rotation_period": rotationPeriod,
        "ssid": ssid,
        "tray_one_date": trayOneDate,
        "tray_three_date": trayThreeDate,
        "tray_two_date": trayTwoDate,
    };
}
