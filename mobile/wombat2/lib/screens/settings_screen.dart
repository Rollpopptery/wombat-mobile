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
      body: _buildSampleList(),
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
  
  Widget _buildSampleList() {
    return ListView.builder(
      itemCount: AppSettings.maxSamples,
      itemBuilder: (context, index) => _buildSampleCard(index),
    );
  }
  
  Widget _buildSampleCard(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSampleTitle(index),
            const SizedBox(height: 8),
            _buildModeSelector(index),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSampleTitle(int index) {
    return Text(
      'Sample $index',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Widget _buildModeSelector(int index) {
    return Row(
      children: [
        Expanded(child: _buildRadioButton(index, SampleMode.add, 'Add')),
        Expanded(child: _buildRadioButton(index, SampleMode.subtract, 'Subtract')),
        Expanded(child: _buildRadioButton(index, SampleMode.ignore, 'Ignore')),
      ],
    );
  }
  
  Widget _buildRadioButton(int index, SampleMode mode, String label) {
    return RadioListTile<SampleMode>(
      title: Text(label),
      value: mode,
      groupValue: _settings.getModeForSample(index),
      onChanged: (value) {
        setState(() {
          _settings.setModeForSample(index, value!);
        });
      },
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