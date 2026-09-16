import 'package:flutter/material.dart';
import '../../../core/audio/sound_service.dart';
import '../../../core/storage/progress_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/campaign/level_generator.dart';
import '../../../domain/models/game_mode.dart';
import '../../../l10n/app_localizations.dart';
import '../game/game_screen.dart';

/// Screen allowing players to configure and generate infinite custom puzzles.
class CustomGameDialog extends StatefulWidget {
  final ProgressStorage storage;
  final SoundService sound;

  const CustomGameDialog({
    super.key,
    required this.storage,
    required this.sound,
  });

  @override
  State<CustomGameDialog> createState() => _CustomGameDialogState();
}

class _CustomGameDialogState extends State<CustomGameDialog> {
  int _selectedGridSize = 5;
  bool _includeWalls = true;
  bool _includeTrampolines = false;
  bool _includeSmartGates = false;
  bool _isGenerating = false;

  void _startGame() async {
    setState(() => _isGenerating = true);
    widget.sound.tileTap();

    // Small microtask to let spinner show if generation takes a frame
    await Future.delayed(const Duration(milliseconds: 100));

    final level = LevelGenerator.generate(
      gridSize: _selectedGridSize,
      includeWalls: _includeWalls,
      wallCount: _selectedGridSize <= 3 ? 0 : (_selectedGridSize == 5 ? 2 : 4),
      includeTrampolines: _includeTrampolines,
      includeSmartGates: _includeSmartGates,
      minTarget: _selectedGridSize * 4,
      maxTarget: _selectedGridSize * 9,
    );

    if (!mounted) return;
    setState(() => _isGenerating = false);
    Navigator.of(context).pop();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(
          initialLevel: level,
          storage: widget.storage,
          sound: widget.sound,
          mode: GameMode.learning,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.cardBorder),
      ),
      title: Row(
        children: [
          const Icon(Icons.tune_rounded, color: AppTheme.pathCyan),
          const SizedBox(width: 8),
          Text(strings.customGame),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.selectBoardSize,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Grid Size Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [3, 5, 7, 9].map((size) {
                final isSelected = _selectedGridSize == size;
                return ChoiceChip(
                  label: Text('${size}x$size'),
                  selected: isSelected,
                  selectedColor: AppTheme.pathCyan,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedGridSize = size);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            const Divider(color: AppTheme.cardBorder),
            const SizedBox(height: 8),

            Text(
              strings.specialElements,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                strings.wallsAndObstacles,
                style: const TextStyle(fontSize: 14),
              ),
              value: _includeWalls,
              activeThumbColor: AppTheme.pathCyan,
              onChanged: _selectedGridSize > 3
                  ? (val) => setState(() => _includeWalls = val)
                  : null,
            ),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                strings.launchPads,
                style: const TextStyle(fontSize: 14),
              ),
              value: _includeTrampolines,
              activeThumbColor: AppTheme.trampolineOrange,
              onChanged: _selectedGridSize > 3
                  ? (val) => setState(() => _includeTrampolines = val)
                  : null,
            ),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                strings.smartGates,
                style: const TextStyle(fontSize: 14),
              ),
              value: _includeSmartGates,
              activeThumbColor: AppTheme.smartGatePurple,
              onChanged: _selectedGridSize > 3
                  ? (val) => setState(() => _includeSmartGates = val)
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            strings.cancel,
            style: const TextStyle(color: AppTheme.textMuted),
          ),
        ),
        ElevatedButton(
          onPressed: _isGenerating ? null : _startGame,
          child: _isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(strings.startGame),
        ),
      ],
    );
  }
}
