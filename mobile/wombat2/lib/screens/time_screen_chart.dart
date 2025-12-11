import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import '../services/usb_service.dart';


class TimeChartScreen extends StatefulWidget {
  final UsbService usbService;
  
  const TimeChartScreen({Key? key, required this.usbService}) : super(key: key);
  
  
  @override
  State<TimeChartScreen> createState() => _TimeChartScreenState();
}

class _TimeChartScreenState extends State<TimeChartScreen> {  
  StreamSubscription<List<double>>? _subscription;
  List<double> _samples = [];
  int _updateCount = 0;
  
  @override
  void initState() {
    super.initState();
    _subscription = widget.usbService.frameStream.listen((samples) {
      if (samples.isNotEmpty) {
        print('Sample count: ${samples.length}, First value: ${samples[0]}, Last value: ${samples[samples.length - 1]}');
      }
      setState(() {
        _samples = samples;
        _updateCount++;
      });
    });  
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [            
            Expanded(child: _buildChart()),
            const SizedBox(height: 16),            
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue[100],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          'Updates: $_updateCount (2 Hz)',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  

  Widget _buildChart() {
    if (_samples.isEmpty) {
      return const Center(
        child: Text('Waiting for data...', style: TextStyle(fontSize: 18)),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(_createChartData()),
      ),
    );
  }

  LineChartData _createChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 500,
        verticalInterval: 2,
      ),
      titlesData: _createTitles(),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.black26),
      ),
      minY: 0,
      maxY: 23000,
      lineBarsData: [_createLineData()],
    );
  }

  FlTitlesData _createTitles() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        axisNameWidget: const Text(''),
        sideTitles: SideTitles(
          showTitles: false,
          reservedSize: 60,
          getTitlesWidget: (value, meta) => Text(
            value.toInt().toString(),
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        axisNameWidget: const Text(''),        
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 4,
          getTitlesWidget: (value, meta) => Text(
            value.toInt().toString(),
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  LineChartBarData _createLineData() {
    return LineChartBarData(
      spots: _samples
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList(),
      isCurved: false,
      color: Colors.blue,
      barWidth: 3,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        color: Colors.blue.withOpacity(0.1),
      ),
    );
  }

  Widget _buildSampleValues() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sample Values:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _samples.length,
                itemBuilder: (context, index) => _buildSampleChip(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleChip(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '[$index]',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          Text(
            _samples[index].toInt().toString(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}