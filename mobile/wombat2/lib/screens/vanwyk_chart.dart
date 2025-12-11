import 'package:flutter/material.dart';
import 'dart:async';
import '../services/usb_service.dart';

class VanWykChart extends StatefulWidget {
  final UsbService usbService;
  
  const VanWykChart({Key? key, required this.usbService}) : super(key: key);
  
  @override
  State<VanWykChart> createState() => _VanWykChartState();
}

class _VanWykChartState extends State<VanWykChart> {
  StreamSubscription<List<double>>? _subscription;
  final List<List<double>> _scanHistory = [];
  static const int maxScans = 50;
  int _scanCounter = 0;
  final int _scanDiv = 1;
  
  // Y-axis zoom and pan state
  double? _minY;
  double? _maxY;
  double _previousScale = 1.0;
  Offset _previousFocalPoint = Offset.zero;
  
  @override
  void initState() {
    super.initState();
    _subscription = widget.usbService.frameStream.listen((samples) {
      _scanCounter++;
      if (_scanCounter % _scanDiv != 0) return;
      
      setState(() {
        _scanHistory.add(samples);
        if (_scanHistory.length > maxScans) {
          _scanHistory.removeAt(0);
        }
      });
    });
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _previousScale = 1.0;
    _previousFocalPoint = details.focalPoint;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_scanHistory.isEmpty) return;
    
    // Initialize Y range on first interaction
    if (_minY == null || _maxY == null) {
      double minValue = double.infinity;
      double maxValue = double.negativeInfinity;
      
      for (var scan in _scanHistory) {
        for (var value in scan) {
          if (value < minValue) minValue = value;
          if (value > maxValue) maxValue = value;
        }
      }
      
      double yRange = maxValue - minValue;
      _minY = minValue - yRange * 0.05;
      _maxY = maxValue + yRange * 0.05;
    }
    
    setState(() {
      // Handle zoom
      if (details.scale != 1.0) {
        double scaleDelta = details.scale / _previousScale;
        _previousScale = details.scale;
        
        double center = (_minY! + _maxY!) / 2;
        double range = _maxY! - _minY!;
        double newRange = range / scaleDelta;
        
        _minY = center - newRange / 2;
        _maxY = center + newRange / 2;
      }
      
      // Handle pan (vertical only)
      double dy = details.focalPoint.dy - _previousFocalPoint.dy;
      _previousFocalPoint = details.focalPoint;
      
      // Convert screen pixels to data units
      double range = _maxY! - _minY!;
      double dataShift = (dy / context.size!.height) * range;
      
      _minY = _minY! + dataShift;
      _maxY = _maxY! + dataShift;
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _previousScale = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: _scanHistory.isEmpty
            ? const Center(
                child: Text(
                  'Waiting for data...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : GestureDetector(
                onScaleStart: _handleScaleStart,
                onScaleUpdate: _handleScaleUpdate,
                onScaleEnd: _handleScaleEnd,
                child: CustomPaint(
                  painter: ScopePainter(_scanHistory, _minY, _maxY),
                  size: Size.infinite,
                ),
              ),
      ),
    );
  }
}

class ScopePainter extends CustomPainter {
  final List<List<double>> scanHistory;
  final double? minY;
  final double? maxY;
  
  ScopePainter(this.scanHistory, this.minY, this.maxY);
  
  @override
  void paint(Canvas canvas, Size size) {
    if (scanHistory.isEmpty) return;
    
    // Use provided Y range or calculate from data
    double minValue = minY ?? double.infinity;
    double maxValue = maxY ?? double.negativeInfinity;
    
    if (minY == null || maxY == null) {
      for (var scan in scanHistory) {
        for (var value in scan) {
          if (value < minValue) minValue = value;
          if (value > maxValue) maxValue = value;
        }
      }
      
      // Add 5% padding to Y range
      double yRange = maxValue - minValue;
      minValue -= yRange * 0.05;
      maxValue += yRange * 0.05;
    }
    
    int numSamples = scanHistory.first.length;
    
    // Draw each sample trace
    for (int sampleIndex = 0; sampleIndex < numSamples; sampleIndex++) {
      Paint paint = Paint()
        ..color = _getColorForSample(sampleIndex, numSamples)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      
      Path path = Path();
      bool firstPoint = true;
      
      for (int scanIndex = 0; scanIndex < scanHistory.length; scanIndex++) {
        if (sampleIndex < scanHistory[scanIndex].length) {
          double x = (scanIndex / (scanHistory.length - 1)) * size.width;
          double normalizedY = (scanHistory[scanIndex][sampleIndex] - minValue) / (maxValue - minValue);
          double y = size.height - (normalizedY * size.height);
          
          if (firstPoint) {
            path.moveTo(x, y);
            firstPoint = false;
          } else {
            path.lineTo(x, y);
          }
        }
      }
      
      canvas.drawPath(path, paint);
    }
  }
  
  Color _getColorForSample(int index, int total) {
    double hue = (index / total) * 360;
    return HSVColor.fromAHSV(1.0, hue, 0.8, 0.9).toColor();
  }
  
  @override
  bool shouldRepaint(ScopePainter oldDelegate) => true;
}