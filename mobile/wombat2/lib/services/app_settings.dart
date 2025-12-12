import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;
  AppSettings._internal();
  
  static const int maxSamples = 25;
  
  // Sample visibility (show/hide)
  List<bool> sampleVisible = List.filled(maxSamples, true);
  
  // Sound plot settings (difference)
  int soundPlotAdd = 0;
  int soundPlotSubtract = 1;
  
  // Conductivity plot settings (ratio)
  int conductivityPlotNumerator = 0;
  int conductivityPlotDenominator = 1;
  
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load sample visibility
    for (int i = 0; i < maxSamples; i++) {
      sampleVisible[i] = prefs.getBool('sample_visible_$i') ?? true;
    }
    
    // Load sound plot settings
    soundPlotAdd = prefs.getInt('sound_add') ?? 0;
    soundPlotSubtract = prefs.getInt('sound_subtract') ?? 1;
    
    // Load conductivity plot settings
    conductivityPlotNumerator = prefs.getInt('conductivity_num') ?? 0;
    conductivityPlotDenominator = prefs.getInt('conductivity_den') ?? 1;
    
    print('Settings loaded');
  }
  
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save sample visibility
    for (int i = 0; i < maxSamples; i++) {
      await prefs.setBool('sample_visible_$i', sampleVisible[i]);
    }
    
    // Save sound plot settings
    await prefs.setInt('sound_add', soundPlotAdd);
    await prefs.setInt('sound_subtract', soundPlotSubtract);
    
    // Save conductivity plot settings
    await prefs.setInt('conductivity_num', conductivityPlotNumerator);
    await prefs.setInt('conductivity_den', conductivityPlotDenominator);
    
    print('Settings saved successfully');
  }
  
  // Get visibility for a specific sample
  bool isSampleVisible(int index) {
    if (index < 0 || index >= maxSamples) return false;
    return sampleVisible[index];
  }
  
  // Set visibility for a specific sample
  void setSampleVisible(int index, bool visible) {
    if (index >= 0 && index < maxSamples) {
      sampleVisible[index] = visible;
    }
  }
}