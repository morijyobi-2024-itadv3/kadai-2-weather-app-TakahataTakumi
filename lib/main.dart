import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show utf8;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('天気予報アプリ'),
        ),
        body: const Center(
          child: CheckHttpResponse(),
        ),
      ),
    );
  }
}

class Weather {
  final String publishingOffice;
  final String reportDatetime;
  final List<TimeSeries> timeSeries;

  Weather({
    required this.publishingOffice,
    required this.reportDatetime,
    required this.timeSeries,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    var timeSeriesFromJson = json['timeSeries'] as List;
    List<TimeSeries> timeSeriesList = timeSeriesFromJson.map((i) => TimeSeries.fromJson(i)).toList();

    return Weather(
      publishingOffice: json['publishingOffice'],
      reportDatetime: json['reportDatetime'],
      timeSeries: timeSeriesList,
    );
  }
}

class TimeSeries {
  final List<String> timeDefines;
  final List<Area> areas;

  TimeSeries({
    required this.timeDefines,
    required this.areas,
  });

  factory TimeSeries.fromJson(Map<String, dynamic> json) {
    var areasFromJson = json['areas'] as List;
    List<Area> areasList = areasFromJson.map((i) => Area.fromJson(i)).toList();

    return TimeSeries(
      timeDefines: List<String>.from(json['timeDefines']),
      areas: areasList,
    );
  }
}

class Area {
  final Map<String, String> area;
  final List<String>? weatherCodes;
  final List<String>? weathers;
  final List<String>? winds;
  final List<String>? waves;

  Area({
    required this.area,
    this.weatherCodes,
    this.weathers,
    this.winds,
    this.waves,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      area: Map<String, String>.from(json['area']),
      weatherCodes: json['weatherCodes'] != null ? List<String>.from(json['weatherCodes']) : null,
      weathers: json['weathers'] != null ? List<String>.from(json['weathers']) : null,
      winds: json['winds'] != null ? List<String>.from(json['winds']) : null,
      waves: json['waves'] != null ? List<String>.from(json['waves']) : null,
    );
  }
}

class CheckHttpResponse extends StatefulWidget {
  const CheckHttpResponse({Key? key}) : super(key: key);

  @override
  _CheckHttpResponseState createState() => _CheckHttpResponseState();
}

class _CheckHttpResponseState extends State<CheckHttpResponse> {
  late Future<List<Weather>> futureWeather = fetchWeather();

  Future<List<Weather>> fetchWeather() async {
    final response = await http.get(Uri.parse('https://www.jma.go.jp/bosai/forecast/data/forecast/030000.json'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((item) => Weather.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load weathers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Weather>>(
      future: futureWeather,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String weather = 'N/A';
          bool found = false;
          for (var weatherData in snapshot.data!) {
            for (var timeSeries in weatherData.timeSeries) {
              for (var area in timeSeries.areas) {
                if (area.area['name'] == '内陸' && area.weathers != null && area.weathers!.isNotEmpty) {
                  weather = area.weathers![0];
                  found = true;
                  break;
                }
              }
              if (found) {
                break;
              }
            }
            if (found) {
              break;
            }
          }
          return Text('岩手県内陸の天気: $weather');
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
}