import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
          title: const Text('HTTP Request Example'),
        ),
        body: const Center(
          child: CheckHttpResponse(),
        ),
      ),
    );
  }
}

class CheckHttpResponse extends StatefulWidget {
  const CheckHttpResponse({Key? key}) : super(key: key);

  @override
  _CheckHttpResponseState createState() => _CheckHttpResponseState();
}

class _CheckHttpResponseState extends State<CheckHttpResponse> {
  late Future<int> _responseCode;

  @override
  void initState() {
    super.initState();
    _responseCode = _checkResponse();
  }

  Future<int> _checkResponse() async {
    final response = await http.get(Uri.parse('https://www.jma.go.jp/bosai/forecast/data/forecast/030000.json'));
    return response.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _responseCode,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text('Error occurred while fetching data');
          } else {
            return Text('Response status code: ${snapshot.data}');
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}