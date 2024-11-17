import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battery Assessment Analysis Results (Web)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        secondaryHeaderColor: Colors.white,
      ),
      home: SensorDataPage(),
    );
  }
}

class SensorDataPage extends StatefulWidget {
  @override
  _SensorDataPageState createState() => _SensorDataPageState();
}

class _SensorDataPageState extends State<SensorDataPage> {
  List<List<dynamic>> sensorData = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    // Fetch data every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    try {
      final String csvData = await rootBundle.loadString('assets/sensor_data.csv');
      List<List<dynamic>> data = const CsvToListConverter().convert(csvData);
      setState(() {
        sensorData = data;
      });
    } catch (e) {
      print('Error reading CSV file: $e');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: sensorData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'AVOIDANCE OF MOBILE BURSTING USING BAA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    _buildModeAndTimestamp(),
                    const SizedBox(height: 16),
                    _buildSensorGrid(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildModeAndTimestamp() {
    final lastData = sensorData.last; // Get the latest data
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.purple.shade700, width: 2),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            'THE CURRENT MODE IS: ${lastData[15]}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Timestamp: ${lastData[14]}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSensorGrid() {
    final lastData = sensorData.last; // Get the latest data
    final sensorMapping = [
      {'label': 'LM35_TEMP1', 'value': '${lastData[0].toStringAsFixed(5)} °C'},
      {'label': 'LM35_TEMP2', 'value': '${lastData[1].toStringAsFixed(5)} °C'},
      {'label': 'LM35_TEMP3', 'value': '${lastData[2].toStringAsFixed(5)} °C'},
      {'label': 'LM35_TEMP4', 'value': '${lastData[3].toStringAsFixed(5)} °C'},
      {'label': 'LM35_TEMP5', 'value': '${lastData[4].toStringAsFixed(5)} °C'},
      {'label': 'LM35_TEMP6', 'value': '${lastData[5].toStringAsFixed(5)} °C'},
      {'label': 'LM35_TEMP7', 'value': '${lastData[6].toStringAsFixed(5)} °C'},
      {'label': 'LM35_TEMP8', 'value': '${lastData[7].toStringAsFixed(5)} °C'},
      {'label': 'DHT_TEMP1', 'value': '${lastData[8].toStringAsFixed(5)} °C'},
      {'label': 'DHT_TEMP2', 'value': '${lastData[9].toStringAsFixed(5)} °C'},
      {'label': 'WEI_AVG_T', 'value': '${lastData[12].toStringAsFixed(5)} °C'},
      {'label': 'CURRENT', 'value': '${lastData[10].toStringAsFixed(5)} Amp'},
      {'label': 'VOLTAGE', 'value': '${lastData[11].toStringAsFixed(5)} V'},
      {'label': 'WATER', 'value': lastData[13] == 1 ? "YES" : "NO"},
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two columns
        childAspectRatio: 2.5, // Adjust to match the desired box shape
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: sensorMapping.length,
      itemBuilder: (context, index) {
        final sensor = sensorMapping[index];
        return _buildSensorBox(sensor['label']!, sensor['value']!);
      },
    );
  }

  Widget _buildSensorBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
        border: Border.all(color: Colors.purple.shade400, width: 2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
