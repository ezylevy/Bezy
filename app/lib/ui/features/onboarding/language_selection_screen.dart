import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key, required this.onLocaleSelected});

  final Future<void> Function(Locale locale) onLocaleSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), AppTheme.bgDark],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.route_rounded,
                      size: 76,
                      color: AppTheme.pathCyan,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'BEZY',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Choose your language\nבחרו שפה',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 20,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 36),
                    _LanguageButton(
                      label: 'English',
                      semanticsLabel: 'Choose English',
                      onPressed: () => onLocaleSelected(const Locale('en')),
                    ),
                    const SizedBox(height: 14),
                    _LanguageButton(
                      label: 'עברית',
                      semanticsLabel: 'בחירת עברית',
                      onPressed: () => onLocaleSelected(const Locale('he')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.label,
    required this.semanticsLabel,
    required this.onPressed,
  });

  final String label;
  final String semanticsLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
