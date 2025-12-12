import 'app_settings.dart';

class CalculatedPlots {
  // Calculate sound plot value (difference)
  static double calculateSoundPlot(List<double> samples, AppSettings settings) {
    int addIndex = settings.soundPlotAdd;
    int subtractIndex = settings.soundPlotSubtract;
    
    if (addIndex >= samples.length || subtractIndex >= samples.length) {
      return 0.0;
    }
    
    return samples[addIndex] - samples[subtractIndex];
  }
  
  // Calculate conductivity plot value (ratio)
  static double calculateConductivityPlot(List<double> samples, AppSettings settings) {
    int numeratorIndex = settings.conductivityPlotNumerator;
    int denominatorIndex = settings.conductivityPlotDenominator;
    
    if (numeratorIndex >= samples.length || denominatorIndex >= samples.length) {
      return 0.0;
    }
    
    double denominator = samples[denominatorIndex];
    if (denominator == 0) {
      return 0.0; // Avoid division by zero
    }
    
    return samples[numeratorIndex] / denominator;
  }
}