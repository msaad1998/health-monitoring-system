// ignore_for_file: library_private_types_in_public_api, unused_field, prefer_const_declarations

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class Reading extends StatefulWidget {
  const Reading({super.key});

  @override
  _ReadingState createState() => _ReadingState();
}

class _ReadingState extends State<Reading> {
  List<Map<String, dynamic>> _dataList = [];
  late Timer _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dataList = [];
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _readECGData();
    });
  }

  Future<void> _readECGData() async {
    setState(() {
      _isLoading = true;
    });

    final url =
        "https://healthmonitoringsystem-557b3-default-rtdb.firebaseio.com/values.json?orderBy=%22\$key%22&limitToLast=1";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null) {
        List<Map<String, dynamic>> dataList = [];
        data.forEach((key, value) {
          final ecg = value["ECG"]?.toStringAsFixed(3) ?? "NULL";
          final spo2 = value["SpO2"]?.toStringAsFixed(3) ?? "NULL";
          final temperature =
              value["Temperature"]?.toStringAsFixed(3) ?? "NULL";
          final heartrate = value["HeartRate"]?.toStringAsFixed(3) ?? "NULL";
          dataList.add({
            "ecg": ecg,
            "spo2": spo2,
            "temperature": temperature,
            "heartrate": heartrate,
          });
        });
        setState(() {
          _dataList = dataList;
          _isLoading = false;
        });
      }
    } else {
      throw Exception('Failed to read data from Firebase');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel(); // Cancel the timer when the widget is disposed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 184, 181, 182),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 184, 181, 182),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          const SizedBox(height: 16),
          const Text(
            'Data from Firebase',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ECG')),
                    DataColumn(label: Text('SpO2')),
                    DataColumn(label: Text('Temperature')),
                    DataColumn(label: Text('HeartRate')),
                  ],
                  rows: _dataList
                      .map((data) => DataRow(cells: [
                            DataCell(
                              Text(
                                data['ecg'],
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            DataCell(
                              Text(
                                data['spo2'],
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            DataCell(
                              Text(
                                data['temperature'],
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            DataCell(Text(
                              data['heartrate'],
                              style: const TextStyle(fontSize: 20),
                            ))
                          ]))
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
