import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import '../services/signal_processor.dart';
import '../models/fft_result.dart';

class FftChartScreen extends StatefulWidget {
  final SignalProcessor processor;
  
  const FftChartScreen({Key? key, required this.processor}) : super(key: key);

  @override
  State<FftChartScreen> createState() => _FftChartScreenState();
}

class _FftChartScreenState extends State<FftChartScreen> {
  StreamSubscription<FftResult>? _subscription;
  List<double> _fftMagnitudes = [];
  double _discriminationRatio = 0.0;
  int _updateCount = 0;
  
  @override
  void initState() {
    super.initState();
    _subscription = widget.processor.fftResultStream.listen((result) {
      setState(() {
        _fftMagnitudes = result.fftMagnitudes;
        _discriminationRatio = result.discriminationRatio;
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
      appBar: AppBar(
        title: const Text('FFT Spectrum'),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            Expanded(child: _buildChart()),
            const SizedBox(height: 16),
            _buildLegend(),
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
        child: Column(
          children: [
            Text(
              'Updates: $_updateCount (2 Hz)',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Ratio: ${_discriminationRatio.toStringAsFixed(2)} - ${_discriminationRatio > 2.0 ? "FERROUS" : "NON-FERROUS"}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _discriminationRatio > 2.0 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_fftMagnitudes.isEmpty) {
      return const Center(
        child: Text('Waiting for FFT data...', style: TextStyle(fontSize: 18)),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(_createChartData()),
      ),
    );
  }

  BarChartData _createChartData() {
    return BarChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false),
      titlesData: _createTitles(),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.black26),
      ),
      barGroups: _createBarGroups(),
      maxY: _getMaxMagnitude() * 1.1,
    );
  }

  FlTitlesData _createTitles() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        axisNameWidget: const Text(
          'Magnitude',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        sideTitles: SideTitles(showTitles: true, reservedSize: 50),
      ),
      bottomTitles: AxisTitles(
        axisNameWidget: const Text(
          'Frequency Bin (~10 kHz per bin)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
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

  List<BarChartGroupData> _createBarGroups() {
    return _fftMagnitudes.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value,
            color: _getBarColor(e.key),
            width: 12,
          ),
        ],
      );
    }).toList();
  }

  Color _getBarColor(int bin) {
    if (bin <= 3) return Colors.red;      // Low freq (ferrous)
    if (bin >= 10) return Colors.green;   // High freq (non-ferrous)
    return Colors.orange;                 // Mid freq
  }

  double _getMaxMagnitude() {
    if (_fftMagnitudes.isEmpty) return 100;
    return _fftMagnitudes.reduce((a, b) => a > b ? a : b);
  }

  Widget _buildLegend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem(Colors.red, 'Bins 0-3: Ferrous'),
            _buildLegendItem(Colors.orange, 'Bins 4-9: Mid'),
            _buildLegendItem(Colors.green, 'Bins 10+: Non-ferrous'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}