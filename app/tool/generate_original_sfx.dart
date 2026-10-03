import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const _sampleRate = 48000;
final _random = Random(0x0be2);

typedef Wave = double Function(double seconds);

double _sine(double frequency, double t) => sin(2 * pi * frequency * t);

Wave _tone(
  double from, {
  double? to,
  double gain = 1,
  double attack = 0.008,
  double release = 0.08,
  double duration = 0.2,
  double start = 0,
}) {
  return (time) {
    final t = time - start;
    if (t < 0 || t >= duration) return 0;
    final progress = t / duration;
    final frequency = from + ((to ?? from) - from) * progress;
    final envelope = min(1.0, t / attack) * min(1.0, (duration - t) / release);
    return _sine(frequency, t) * gain * envelope;
  };
}

Wave _noise({
  double gain = 0.2,
  double duration = 0.12,
  double release = 0.06,
  double start = 0,
}) {
  final values = List<double>.generate(
    (duration * _sampleRate).ceil(),
    (_) => _random.nextDouble() * 2 - 1,
  );
  return (time) {
    final t = time - start;
    if (t < 0 || t >= duration) return 0;
    final index = min(values.length - 1, (t * _sampleRate).floor());
    final envelope = min(1.0, (duration - t) / release);
    return values[index] * gain * envelope;
  };
}

Wave _mix(List<Wave> waves) => (time) {
  var value = 0.0;
  for (final wave in waves) {
    value += wave(time);
  }
  return value;
};

Future<void> _write(String name, double seconds, Wave wave) async {
  final sampleCount = (seconds * _sampleRate).ceil();
  final dataSize = sampleCount * 2;
  final bytes = ByteData(44 + dataSize);
  void ascii(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      bytes.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  bytes.setUint32(4, 36 + dataSize, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  bytes.setUint32(16, 16, Endian.little);
  bytes.setUint16(20, 1, Endian.little);
  bytes.setUint16(22, 1, Endian.little);
  bytes.setUint32(24, _sampleRate, Endian.little);
  bytes.setUint32(28, _sampleRate * 2, Endian.little);
  bytes.setUint16(32, 2, Endian.little);
  bytes.setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  bytes.setUint32(40, dataSize, Endian.little);
  for (var i = 0; i < sampleCount; i++) {
    final value = (wave(i / _sampleRate) * 0.82).clamp(-1.0, 1.0);
    bytes.setInt16(44 + i * 2, (value * 32767).round(), Endian.little);
  }
  final directory = Directory('assets/audio/sfx');
  await directory.create(recursive: true);
  await File(
    '${directory.path}/$name.wav',
  ).writeAsBytes(bytes.buffer.asUint8List());
}

Future<void> main() async {
  final sounds = <String, (double, Wave)>{
    'ui_tap': (0.10, _tone(720, to: 900, duration: 0.09, release: 0.05)),
    'toggle_on': (
      0.24,
      _mix([
        _tone(520, duration: 0.12),
        _tone(780, start: 0.08, duration: 0.15),
      ]),
    ),
    'tile_start': (
      0.28,
      _mix([
        _tone(330, to: 480, duration: 0.24),
        _tone(660, start: 0.08, duration: 0.18, gain: 0.45),
      ]),
    ),
    'tile_enter_01': (0.12, _tone(610, to: 690, duration: 0.11)),
    'tile_enter_02': (0.12, _tone(680, to: 760, duration: 0.11)),
    'tile_enter_03': (0.12, _tone(750, to: 830, duration: 0.11)),
    'tile_backtrack': (0.16, _tone(720, to: 430, duration: 0.15)),
    'reset': (
      0.34,
      _mix([
        _tone(760, to: 220, duration: 0.31),
        _noise(gain: 0.05, duration: 0.22),
      ]),
    ),
    'move_invalid': (
      0.18,
      _mix([_tone(170, duration: 0.16), _tone(153, duration: 0.16, gain: 0.5)]),
    ),
    'wall_blocked': (
      0.14,
      _mix([
        _tone(105, duration: 0.12, gain: 0.7),
        _noise(gain: 0.12, duration: 0.05),
      ]),
    ),
    'gate_closed': (
      0.25,
      _mix([
        _tone(260, to: 190, duration: 0.16),
        _tone(130, start: 0.12, duration: 0.1),
      ]),
    ),
    'locked_stage': (
      0.27,
      _mix([
        _tone(300, duration: 0.1),
        _tone(230, start: 0.11, duration: 0.14),
      ]),
    ),
    'teleport': (
      0.55,
      _mix([
        _tone(240, to: 1180, duration: 0.35, gain: 0.55),
        _noise(gain: 0.08, duration: 0.34),
        _tone(1320, start: 0.34, duration: 0.18),
      ]),
    ),
    'gate_open': (
      0.38,
      _mix([
        _tone(260, to: 520, duration: 0.24),
        _tone(780, start: 0.17, duration: 0.18, gain: 0.55),
      ]),
    ),
    'target_reached': (
      0.42,
      _mix([
        _tone(523, duration: 0.35),
        _tone(784, start: 0.07, duration: 0.32, gain: 0.7),
      ]),
    ),
    'victory_sting': (
      1.25,
      _mix([
        _tone(392, duration: 0.34),
        _tone(523, start: 0.22, duration: 0.36),
        _tone(659, start: 0.46, duration: 0.42),
        _tone(784, start: 0.72, duration: 0.5, gain: 0.8),
      ]),
    ),
    'stage_unlock': (
      0.92,
      _mix([
        _noise(gain: 0.12, duration: 0.18, release: 0.12),
        _tone(180, to: 1120, duration: 0.38, gain: 0.62),
        _tone(523, start: 0.24, duration: 0.18, gain: 0.72),
        _tone(659, start: 0.36, duration: 0.18, gain: 0.76),
        _tone(880, start: 0.48, duration: 0.20, gain: 0.82),
        _tone(1318, start: 0.61, duration: 0.28, gain: 0.72),
      ]),
    ),
    'message_report': (
      0.62,
      _mix([
        _tone(740, duration: 0.11, gain: 0.62),
        _tone(520, start: 0.10, duration: 0.12, gain: 0.68),
        _tone(930, start: 0.22, duration: 0.15, gain: 0.76),
        _tone(1175, to: 880, start: 0.36, duration: 0.23, gain: 0.58),
      ]),
    ),
    'map_open': (
      0.32,
      _mix([
        _tone(190, to: 510, duration: 0.3, gain: 0.45),
        _noise(gain: 0.035, duration: 0.26),
      ]),
    ),
    'joker_reveal': (
      0.42,
      _mix([
        _tone(880, duration: 0.18),
        _tone(1175, start: 0.13, duration: 0.26),
      ]),
    ),
    'joker_choose': (
      0.28,
      _mix([
        _tone(440, duration: 0.2),
        _tone(880, start: 0.07, duration: 0.19, gain: 0.55),
      ]),
    ),
    'ice_slide': (
      0.42,
      _mix([
        _tone(950, to: 1450, duration: 0.39, gain: 0.28),
        _noise(gain: 0.035, duration: 0.37),
      ]),
    ),
    'mirror': (
      0.40,
      _mix([
        _tone(920, to: 430, duration: 0.36),
        _tone(430, to: 920, duration: 0.36, gain: 0.34),
      ]),
    ),
    'clone': (
      0.34,
      _mix([
        _tone(610, duration: 0.2),
        _tone(610, start: 0.1, duration: 0.22, gain: 0.6),
      ]),
    ),
    'zero': (0.35, _tone(800, to: 70, duration: 0.32)),
    'black_hole': (
      0.48,
      _mix([
        _tone(260, to: 45, duration: 0.45),
        _noise(gain: 0.07, duration: 0.4),
      ]),
    ),
    'bomb': (
      0.30,
      _mix([
        _tone(92, to: 45, duration: 0.27, gain: 0.8),
        _noise(gain: 0.22, duration: 0.18),
      ]),
    ),
    'lonely_locked': (
      0.34,
      _mix([
        for (var i = 0; i < 4; i++)
          _tone(300, start: i * 0.07, duration: 0.06, gain: 0.45),
      ]),
    ),
    'lonely_unlock': (
      0.55,
      _mix([
        for (var i = 0; i < 4; i++)
          _tone(340 + i * 70, start: i * 0.07, duration: 0.09, gain: 0.38),
        _tone(680, start: 0.29, duration: 0.24),
      ]),
    ),
    'hint': (
      0.48,
      _mix([
        _tone(740, to: 1080, duration: 0.3, gain: 0.5),
        _tone(1480, start: 0.22, duration: 0.22, gain: 0.35),
      ]),
    ),
    'solution_preview': (
      0.48,
      _mix([
        _tone(360, to: 920, duration: 0.44, gain: 0.38),
        _tone(720, to: 1380, duration: 0.44, gain: 0.22),
      ]),
    ),
    'solution_step': (0.09, _tone(520, duration: 0.08, gain: 0.5)),
    'timer_warning': (
      0.24,
      _mix([
        _tone(650, duration: 0.09),
        _tone(650, start: 0.13, duration: 0.09),
      ]),
    ),
    'timer_final_tick': (
      0.12,
      _mix([_tone(1100, duration: 0.1), _noise(gain: 0.04, duration: 0.04)]),
    ),
    'time_up': (
      0.64,
      _mix([
        _tone(440, to: 180, duration: 0.58),
        _tone(220, start: 0.3, duration: 0.3, gain: 0.45),
      ]),
    ),
    'star_earned': (
      0.30,
      _mix([
        _tone(990, duration: 0.2),
        _tone(1480, start: 0.08, duration: 0.2, gain: 0.45),
      ]),
    ),
  };

  for (final entry in sounds.entries) {
    await _write(entry.key, entry.value.$1, entry.value.$2);
  }
  stdout.writeln('Generated ${sounds.length} original BEZY sound effects.');
}
