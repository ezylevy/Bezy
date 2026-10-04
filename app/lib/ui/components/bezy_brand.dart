import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The BEZY logo artwork (tile board + neon "BEZY" lettering).
const String kBezyLogoAsset = 'assets/logos/bezy_logo.png';

/// Deep navy tones sampled from the app icon's stone tile.
const Color kBezyBgCenter = Color(0xFF202C54);
const Color kBezyBgEdge = Color(0xFF0B1020);

/// Static BEZY logo used wherever the brand appears (language screen, board).
class BezyLogo extends StatelessWidget {
  const BezyLogo({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'BEZY',
      image: true,
      child: Image.asset(
        kBezyLogoAsset,
        height: height,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        excludeFromSemantics: true,
      ),
    );
  }
}

/// Home-screen logo with a one-shot motion-graphic intro on every app launch:
/// the logo springs in with a slight twist, a neon glow blooms behind it and a
/// light sweep crosses the lettering. It ends static, so it never loops.
class AnimatedBezyLogo extends StatefulWidget {
  const AnimatedBezyLogo({super.key, required this.height});

  final double height;

  @override
  State<AnimatedBezyLogo> createState() => _AnimatedBezyLogoState();
}

class _AnimatedBezyLogoState extends State<AnimatedBezyLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );

  static const _enter = Interval(0, 0.55);
  static const _fade = Interval(0, 0.3, curve: Curves.easeOut);
  static const _sweep = Interval(0.5, 0.95, curve: Curves.easeInOut);
  static const _bloom = Interval(0.2, 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logo = BezyLogo(height: widget.height);
    return SizedBox(
      key: const ValueKey('home-bezy-logo'),
      height: widget.height * 1.12,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final enterLinear = _enter.transform(t);
          final enter = Curves.easeOutBack.transform(enterLinear);
          final opacity = _fade.transform(t);
          final sweep = _sweep.transform(t);
          // Glow rises, peaks, then settles to a soft resting halo.
          final bloomPhase = _bloom.transform(t);
          final glow = 0.35 + 0.65 * math.sin(bloomPhase * math.pi);
          final settled = t >= 1 ? 0.35 : glow;

          Widget art = child!;
          if (sweep > 0 && sweep < 1) {
            final center = -0.2 + 1.4 * sweep;
            art = ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.55),
                  Colors.white.withValues(alpha: 0),
                ],
                stops: [
                  (center - 0.12).clamp(0.0, 1.0),
                  center.clamp(0.0, 1.0),
                  (center + 0.12).clamp(0.0, 1.0),
                ],
              ).createShader(rect),
              child: art,
            );
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: opacity * settled,
                child: Container(
                  width: widget.height * 0.95,
                  height: widget.height * 0.95,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF22D3EE).withValues(alpha: 0.45),
                        const Color(0xFFD946EF).withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                      stops: const [0, 0.55, 1],
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: opacity,
                child: Transform.rotate(
                  angle: (1 - enterLinear) * -0.18,
                  child: Transform.scale(
                    scale: 0.35 + 0.65 * enter,
                    child: art,
                  ),
                ),
              ),
            ],
          );
        },
        child: logo,
      ),
    );
  }
}

/// Full-screen background matching the app icon: a navy radial glow over a
/// faint diagonal tile grid.
class BezyBackground extends StatelessWidget {
  const BezyBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.35),
          radius: 1.15,
          colors: [kBezyBgCenter, kBezyBgEdge],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const IgnorePointer(child: CustomPaint(painter: _TileGridPainter())),
          child,
        ],
      ),
    );
  }
}

class _TileGridPainter extends CustomPainter {
  const _TileGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5A8CFF).withValues(alpha: 0.07)
      ..strokeWidth = 1.5;
    const step = 56.0;
    final span = size.height;
    for (var x = -span; x < size.width + span; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x + span, span), paint);
      canvas.drawLine(Offset(x + span, 0), Offset(x, span), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TileGridPainter oldDelegate) => false;
}
