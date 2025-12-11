import 'package:flutter/material.dart';
import '../services/usb_service.dart';
import 'time_screen_chart.dart';
import 'vanwyk_chart.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final UsbService _usbService = UsbService();
    
  String _status = 'Initializing...';
  int _frameCount = 0;
  int _linesDropped = 0;  
  
  @override
  void initState() {
    super.initState();
    _initializeDetector();
  }

  Future<void> _initializeDetector() async {
    bool connected = await _usbService.connect();
    
    if (!connected) {
      setState(() {
        _status = 'Failed to connect to USB device';
      });
      return;
    }
    
    setState(() {
      _status = 'Connected';
    });
    
    // USB frames update counter
    _usbService.frameStream.listen((samples) {
      setState(() {
        _frameCount = _usbService.framesReceived;
        _linesDropped = _usbService.linesDropped;
      });
    });
  }

  @override
  void dispose() async {
    await _usbService.disconnect();
    _usbService.dispose();   
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metal Detector'),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status card
            Card(
              color: Colors.blue[800],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: $_status',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Frames received: $_frameCount',
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    if (_linesDropped > 0)
                      Text(
                        'Lines dropped: $_linesDropped',
                        style: const TextStyle(fontSize: 14, color: Colors.orange),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VanWykChart(usbService: _usbService),
                  ),
                );
              },
              icon: const Icon(Icons.timeline),
              label: const Text('View VanWyk Chart'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Navigation button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimeChartScreen(usbService: _usbService),
                  ),
                );
              },
              icon: const Icon(Icons.show_chart),
              label: const Text('View Time Domain Chart'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
