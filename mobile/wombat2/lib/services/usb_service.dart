import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:usb_serial/usb_serial.dart';

class UsbService {
  UsbPort? _port;
  StreamSubscription<Uint8List>? _subscription;
  
  final StreamController<List<double>> _frameController = StreamController<List<double>>.broadcast();
  Stream<List<double>> get frameStream => _frameController.stream;
  
  String _buffer = '';
  int _framesReceived = 0;
  int _linesDropped = 0;
  
  int get framesReceived => _framesReceived;
  int get linesDropped => _linesDropped;

  Future<bool> connect() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    
    if (devices.isEmpty) {
      return false;
    }

    UsbDevice device = devices.first;
    _port = await device.create();
    
    bool openResult = await _port!.open();
    if (!openResult) {
      return false;
    }
    
    await _port!.setPortParameters(
      230400,
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE
    );

    _subscription = _port!.inputStream!.listen(_onDataReceived);
    return true;
  }

  void _onDataReceived(Uint8List data) {
    

    // Convert bytes to string and add to buffer
    String incoming = utf8.decode(data, allowMalformed: true);
    _buffer += incoming;
    
    // Process complete lines (delimited by newline)
    while (_buffer.contains('\n')) {
      int newlineIndex = _buffer.indexOf('\n');
      String line = _buffer.substring(0, newlineIndex).trim();
      _buffer = _buffer.substring(newlineIndex + 1);
      
      if (line.isNotEmpty) {
        _parseLine(line);
      }
    }
    
    // Prevent buffer from growing too large
    if (_buffer.length > 1000) {
      _buffer = '';
      _linesDropped++;
    }
  }
    

  void _parseLine(String line) {
    try {
      //print('Raw line: $line');
      // Split by comma and parse as doubles
      List<String> parts = line.split(',');
      List<double> samples = [];
      
      for (String part in parts) {
        String trimmed = part.trim();
        if (trimmed.isNotEmpty) {
          double? value = double.tryParse(trimmed);
          if (value != null) {
            samples.add(value);
          }
        }
      }
      
      // Only emit if we have samples
      if (samples.isNotEmpty) {
        _framesReceived++;        
        _frameController.add(samples);
      }
    } catch (e) {
      // Skip malformed lines
      _linesDropped++;
    }
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _port?.close();
    _port = null;
    _buffer = '';
    _framesReceived = 0;
    _linesDropped = 0;
  }

  void dispose() {
    _subscription?.cancel();
    _port?.close();
    _frameController.close();
  }
}
