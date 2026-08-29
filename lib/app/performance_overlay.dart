import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerformanceOverlayToggle extends StatefulWidget {
  const PerformanceOverlayToggle({super.key});

  @override
  State<PerformanceOverlayToggle> createState() => _PerformanceOverlayToggleState();
}

class _PerformanceOverlayToggleState extends State<PerformanceOverlayToggle> {
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enabled = prefs.getBool('perf_overlay') ?? false;
    });
  }

  Future<void> _toggle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enabled = !_enabled;
      prefs.setBool('perf_overlay', _enabled);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Performance Overlay'),
      subtitle: const Text('Show FPS and rendering stats'),
      value: _enabled,
      onChanged: (_) => _toggle(),
    );
  }
}
