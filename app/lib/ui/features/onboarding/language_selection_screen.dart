import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../components/bezy_brand.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key, required this.onLocaleSelected});

  final Future<void> Function(Locale locale) onLocaleSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BezyBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const BezyLogo(height: 190),
                    const SizedBox(height: 18),
                    const Text(
                      'Choose your language\nבחרו שפה',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 24,
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
