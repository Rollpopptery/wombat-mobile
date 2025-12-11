class FftResult {
  final List<double> averagedSamples;
  final List<double> fftMagnitudes;
  final double discriminationRatio;
  final DateTime timestamp;
  
  FftResult({
    required this.averagedSamples,
    required this.fftMagnitudes,
    required this.discriminationRatio,
    required this.timestamp,
  });
}