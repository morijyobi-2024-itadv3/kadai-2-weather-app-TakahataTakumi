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
  final String pref;
  final String area;
  final WeatherDetail today;
  final WeatherDetail tomorrow;

  Weather({
    required this.pref,
    required this.area,
    required this.today,
    required this.tomorrow,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      pref: json['pref'],
      area: json['area'],
      today: WeatherDetail.fromJson(json['today']),
      tomorrow: WeatherDetail.fromJson(json['tomorrow']),
    );
  }
}

class WeatherDetail {
  final String weather;
  final String maxtemp;
  final String mintemp;

  WeatherDetail({
    required this.weather,
    required this.maxtemp,
    required this.mintemp,
  });

  factory WeatherDetail.fromJson(Map<String, dynamic> json) {
    return WeatherDetail(
      weather: json['weather'],
      maxtemp: json['maxtemp'],
      mintemp: json['mintemp'],
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
          String todayWeather = 'N/A';
          String tomorrowWeather = 'N/A';
          bool found = false;
          for (var weatherData in snapshot.data!) {
            for (var timeSeries in weatherData.timeSeries) {
              for (var area in timeSeries.areas) {
                if (area.area['name'] == '内陸' && area.weathers != null && area.weathers!.length >= 2) {
                  todayWeather = area.weathers![0];
                  tomorrowWeather = area.weathers![1];
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
          return Column(
            children: <Widget>[
              Text('岩手県内陸の今日の天気: $todayWeather'),
              Text('岩手県内陸の明日の天気: $tomorrowWeather'),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
}