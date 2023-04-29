// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_declarations, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Reading extends StatefulWidget {
  @override
  _ReadingState createState() => _ReadingState();
}

class _ReadingState extends State<Reading> {
  List<Map<String, dynamic>> _dataList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dataList = [];
  }

  Future<void> _readECGData() async {
    setState(() {
      _isLoading = true;
    });

    final url =
        "https://healthmonitoringsystem-557b3-default-rtdb.firebaseio.com/all.json";

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
          dataList.add({
            "ecg": ecg,
            "spo2": spo2,
            "temperature": temperature,
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(200, 60),
              primary: const Color.fromARGB(255, 92, 100, 104),
              shape: RoundedRectangleBorder(
                  //to set border radius to button
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: _isLoading ? null : _readECGData,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(),
                  )
                : const Text('Readings'),
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
                  ],
                  rows: _dataList
                      .map((data) => DataRow(cells: [
                            DataCell(
                              Text(
                                data['ecg'],
                                style: const TextStyle(fontSize: 25),
                              ),
                            ),
                            DataCell(
                              Text(
                                data['spo2'],
                                style: const TextStyle(fontSize: 25),
                              ),
                            ),
                            DataCell(
                              Text(
                                data['temperature'],
                                style: const TextStyle(fontSize: 25),
                              ),
                            ),
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
