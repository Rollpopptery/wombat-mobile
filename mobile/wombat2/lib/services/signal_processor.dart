import 'dart:async';
import 'dart:math';
import '../models/fft_result.dart';

class SignalProcessor {
  final List<List<double>> _frameBuffer = [];
  Timer? _fftTimer;
  
  final StreamController<FftResult> _fftResultController = StreamController<FftResult>.broadcast();
  Stream<FftResult> get fftResultStream => _fftResultController.stream;

  void addFrame(List<double> samples) {
    _frameBuffer.add(samples);
    
    // Keep last 25 frames (500ms at 50 Hz)
    if (_frameBuffer.length > 25) {
      _frameBuffer.removeAt(0);
    }
  }

  void startPeriodicFFT() {
    _fftTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_frameBuffer.length == 25) {
        _computeAndPublishFFT();
      }
    });
  }

  void _computeAndPublishFFT() {
    List<double> averaged = _computeAverage();
    List<double> padded = _padTo32(averaged);
    List<double> fftMags = _computeFFT(padded);
    double ratio = _computeDiscriminationRatio(fftMags);
    
    FftResult result = FftResult(
      averagedSamples: averaged,
      fftMagnitudes: fftMags,
      discriminationRatio: ratio,
      timestamp: DateTime.now(),
    );
    
    _fftResultController.add(result);
  }

  List<double> _computeAverage() {
    if (_frameBuffer.isEmpty) return [];
    
    int sampleCount = _frameBuffer.first.length;
    List<double> avg = List.filled(sampleCount, 0.0);
    
    for (var frame in _frameBuffer) {
      for (int i = 0; i < frame.length && i < sampleCount; i++) {
        avg[i] += frame[i];
      }
    }
    
    return avg.map((v) => v / _frameBuffer.length).toList();
  }

  List<double> _padTo32(List<double> samples) {
    if (samples.length >= 32) {
      return samples.sublist(0, 32);
    }
    return [
      ...samples,
      ...List<double>.filled(32 - samples.length, 0.0)
    ];
  }

  List<double> _computeFFT(List<double> samples) {
    // Simple DFT (Direct Fourier Transform) for now
    // You can replace with a proper FFT library later
    int N = samples.length;
    List<double> magnitudes = [];
    
    for (int k = 0; k < N ~/ 2; k++) {
      double real = 0;
      double imag = 0;
      
      for (int n = 0; n < N; n++) {
        double angle = -2 * pi * k * n / N;
        real += samples[n] * cos(angle);
        imag += samples[n] * sin(angle);
      }
      
      double magnitude = sqrt(real * real + imag * imag);
      magnitudes.add(magnitude);
    }
    
    return magnitudes;
  }

  double _computeDiscriminationRatio(List<double> fftMags) {
    if (fftMags.length < 15) return 0.0;
    
    // Low freq energy (bins 1-3): ferrous signature
    double lowFreq = fftMags[1] + fftMags[2] + fftMags[3];
    
    // High freq energy (bins 10-14): non-ferrous signature
    double highFreq = fftMags[10] + fftMags[11] + fftMags[12] + fftMags[13] + fftMags[14];
    
    if (highFreq == 0) return 999.0;
    return lowFreq / highFreq;
  }

  void dispose() {
    _fftTimer?.cancel();
    _fftResultController.close();
  }
}