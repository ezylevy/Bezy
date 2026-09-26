import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

Future<void> showBezyMessageDialog(
  BuildContext context, {
  required String message,
}) {
  final strings = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    builder: (dialogContext) {
      final screen = MediaQuery.sizeOf(dialogContext);
      final width = math.min(screen.width - 24, 680.0);
      final charactersPerLine = math.max(18, (width / 10.5).floor());
      final estimatedLines = message
          .split('\n')
          .fold<int>(
            0,
            (total, paragraph) =>
                total +
                math.max(1, (paragraph.length / charactersPerLine).ceil()),
          );
      final naturalHeight = math.max(width / 1.5, 190.0 + estimatedLines * 27);
      final height = math.min(naturalHeight, screen.height * 0.84);

      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: SizedBox(
          key: const ValueKey('bezy-message-frame'),
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/buttons/msg.png',
                fit: BoxFit.fill,
                filterQuality: FilterQuality.medium,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  width * 0.09,
                  height * 0.17,
                  width * 0.09,
                  height * 0.12,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 19,
                              height: 1.35,
                              fontWeight: FontWeight.w800,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 5),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.pathCyan,
                        foregroundColor: AppTheme.bgDark,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 10,
                        ),
                      ),
                      child: Text(strings.close),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
