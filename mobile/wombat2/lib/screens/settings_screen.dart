import 'package:flutter/material.dart';
import '../services/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppSettings _settings = AppSettings();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settings.load();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildSettingsList(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Sample Settings'),
      backgroundColor: Colors.blue[900],
      actions: [
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: _saveSettings,
          tooltip: 'Save Settings',
        ),
      ],
    );
  }

  Widget _buildSettingsList() {
    return ListView(
      children: [
        // Sample visibility toggles
        ..._buildSampleToggles(),
        
        const Divider(thickness: 2),
        
        // Sound plot settings
        _buildDerivedPlotCard(
          'Sound Plot',
          'Calculation: + minus -',
          _settings.soundPlotAdd,
          _settings.soundPlotSubtract,
          '+',
          '-',
          (add) => setState(() => _settings.soundPlotAdd = add),
          (sub) => setState(() => _settings.soundPlotSubtract = sub),
        ),
        
        // Conductivity plot settings
        _buildDerivedPlotCard(
          'Conductivity Plot',
          'Calculation: + divided by /',
          _settings.conductivityPlotNumerator,
          _settings.conductivityPlotDenominator,
          '+',
          '/',
          (num) => setState(() => _settings.conductivityPlotNumerator = num),
          (den) => setState(() => _settings.conductivityPlotDenominator = den),
        ),
      ],
    );
  }

  List<Widget> _buildSampleToggles() {
    return List.generate(AppSettings.maxSamples, (index) {
      return SwitchListTile(
        title: Text('Sample $index'),
        value: _settings.isSampleVisible(index),
        onChanged: (value) {
          setState(() {
            _settings.setSampleVisible(index, value);
          });
        },
      );
    });
  }

  Widget _buildDerivedPlotCard(
    String title,
    String description,
    int value1,
    int value2,
    String label1,
    String label2,
    Function(int) onValue1Changed,
    Function(int) onValue2Changed,
  ) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(label1, value1, onValue1Changed),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(label2, value2, onValue2Changed),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<int>(
          value: value,
          isExpanded: true,
          items: List.generate(
            AppSettings.maxSamples,
            (i) => DropdownMenuItem(value: i, child: Text('Sample $i')),
          ),
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ],
    );
  }

  void _saveSettings() async {
    await _settings.save();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}