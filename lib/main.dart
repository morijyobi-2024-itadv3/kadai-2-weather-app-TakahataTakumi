import 'dart:convert';

import 'package:flutter/cupertino.dart';
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
    final response = await http
        .get(Uri.parse('ngrokUrl'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));

      return [Weather.fromJson(jsonResponse)];
    } else {
      throw Exception('Failed to load weather');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Weather>>(
      future: futureWeather,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: <Widget>[
              Text('都道府県: ${snapshot.data![0].pref ?? 'N/A'}'),
              Text('地域: ${snapshot.data![0].area ?? 'N/A'}'),
              Text('今日の天気: ${snapshot.data![0].today.weather}'),
              Text('最高気温: ${snapshot.data![0].today.maxtemp}'),
              Text('最低気温: ${snapshot.data![0].today.mintemp}'),
              Text('明日の天気: ${snapshot.data![0].tomorrow.weather}'),
              Text('最高気温: ${snapshot.data![0].tomorrow.maxtemp}'),
              Text('最低気温: ${snapshot.data![0].tomorrow.mintemp}'),
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
