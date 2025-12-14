import 'package:flutter_soloud/flutter_soloud.dart';
import 'dart:math';

class AudioService {
  final SoLoud _soloud = SoLoud.instance;
  AudioSource? _waveform;
  SoundHandle? _handle;
  bool _isPlaying = false;
  
  // Tone parameters
  static const double centerFrequency = 500.0;
  static const double minFrequency = 400.0;
  static const double maxFrequency = 1200.0;
  static const double minVolume = 0.1;
  static const double maxVolume = 1.0;
  
  Future<void> init() async {
    try {
      await _soloud.init(
        bufferSize: 512,        // Low latency!
        sampleRate: 48000,       // 48kHz for Android low latency
        channels: Channels.mono, // Mono = lower latency
      );
      print('SoLoud initialized successfully');
    } catch (e) {
      print('Failed to init audio: $e');
    }
  }

  Future<void> start() async {
    if (_isPlaying) return;
    _isPlaying = true;
    
    try {
      _waveform = await _soloud.loadWaveform(
        WaveForm.sin,
        false,
        1.0,
        0.0,  // No detune
      );
      
      // Set frequency BEFORE playing
      _soloud.setWaveformFreq(_waveform!, centerFrequency);
      
      _handle = await _soloud.play(_waveform!);
      
      print('Playing at ${centerFrequency}Hz');
    } catch (e) {
      print('Failed to start audio: $e');
    }
  }
  
  Future<void> stop() async {
    if (!_isPlaying) return;
    _isPlaying = false;
    
    try {
      if (_handle != null) {
        await _soloud.stop(_handle!);
      }
    } catch (e) {
      print('Failed to stop audio: $e');
    }
  }
  
  void updateSignal(double signalValue) {
    if (!_isPlaying || _waveform == null || _handle == null) return;
    
    double normalized = signalValue.clamp(0, 1000) / 1000;
    double sensitiveSignal = sqrt(normalized);
    
    double frequency = minFrequency + (sensitiveSignal * (maxFrequency - minFrequency));
    double volume = minVolume + (sensitiveSignal * (maxVolume - minVolume));
    
    // Update frequency on SOURCE and volume on HANDLE
    _soloud.setWaveformFreq(_waveform!, frequency);
    _soloud.setVolume(_handle!, volume);
  }
  
  void dispose() {
    stop();
  }
}