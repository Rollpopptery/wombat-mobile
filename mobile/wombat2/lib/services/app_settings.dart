import 'package:shared_preferences/shared_preferences.dart';

enum SampleMode { add, subtract, ignore }

class AppSettings {
  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;
  AppSettings._internal();
  
  static const int maxSamples = 25;
  List<SampleMode> sampleModes = List.filled(maxSamples, SampleMode.ignore);
  
  Future<void> load() async {
  final prefs = await SharedPreferences.getInstance();
  
  for (int i = 0; i < maxSamples; i++) {
    String? modeStr = prefs.getString('sample_mode_$i');
    print('Loaded sample $i: $modeStr');
    if (modeStr != null) {
      sampleModes[i] = SampleMode.values.firstWhere(
        (e) => e.name == modeStr,
        orElse: () => SampleMode.ignore,
      );
    }
  }
  print('Settings loaded');
}
  
  Future<void> save() async {
  final prefs = await SharedPreferences.getInstance();
  
  for (int i = 0; i < maxSamples; i++) {
    await prefs.setString('sample_mode_$i', sampleModes[i].name);
    print('Saved sample $i as ${sampleModes[i].name}');
  }
  print('Settings saved successfully');
}
  
  // Get mode for a specific sample
  SampleMode getModeForSample(int index) {
    if (index < 0 || index >= maxSamples) return SampleMode.ignore;
    return sampleModes[index];
  }
  
  // Set mode for a specific sample
  void setModeForSample(int index, SampleMode mode) {
    if (index >= 0 && index < maxSamples) {
      sampleModes[index] = mode;
    }
  }
}