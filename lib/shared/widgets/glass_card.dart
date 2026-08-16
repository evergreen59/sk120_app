import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color,
    this.borderColor,
    this.onTap,
    this.radius = AppRadius.large,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;
  final BorderRadius radius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? AppColors.surface,
            borderRadius: radius,
            border: Border.all(color: borderColor ?? AppColors.border),
            boxShadow: AppShadows.glass,
          ),
          child: child,
        ),
      ),
    );
    return onTap == null
        ? card
        : InkWell(onTap: onTap, borderRadius: radius, child: card);
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.child, this.padding, this.color});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) => GlassCard(
    padding: padding ?? EdgeInsets.zero,
    color: color,
    child: child,
  );
}

void showGlassToast(
  BuildContext context,
  String message, {
  Color color = AppColors.green,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      top: MediaQuery.paddingOf(context).top + 16,
      left: 24,
      right: 24,
      child: Center(
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          radius: AppRadius.medium,
          color: color.withValues(alpha: 0.16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                message,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Timer(const Duration(seconds: 2), entry.remove);
}

class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.primary = false,
    this.color = AppColors.electricBlue,
    this.expand = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool primary;
  final Color color;
  final bool expand;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final button = GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            gradient: widget.primary
                ? LinearGradient(
                    colors: [
                      widget.color,
                      widget.color.withValues(alpha: 0.72),
                    ],
                  )
                : null,
            color: widget.primary ? null : AppColors.surfaceStrong,
            borderRadius: AppRadius.medium,
            border: Border.all(color: widget.color.withValues(alpha: 0.42)),
            boxShadow: widget.primary
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.28),
                      blurRadius: 18,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: DefaultTextStyle.merge(
              style: const TextStyle(fontWeight: FontWeight.w700),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
    return widget.expand ? Expanded(child: button) : button;
  }
}

class ToggleSwitch extends StatelessWidget {
  const ToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.color = AppColors.green,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onChanged == null ? null : () => onChanged!(!value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      // Back/elastic curves overshoot the 0..1 interval. BoxShadow.lerp then
      // extrapolates 14 -> 0 to a negative blur radius and asserts in dart:ui.
      // Keep spring-like motion on the knob below, but use a bounded curve for
      // the decoration interpolation.
      curve: Curves.easeOutCubic,
      width: 56,
      height: 32,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: value
            ? color.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: AppRadius.pill,
        border: Border.all(color: value ? color : AppColors.border),
        // Keep both animation endpoints non-null. Interpolating a populated
        // shadow list to null can produce a negative blur radius in Flutter's
        // BoxDecoration lerp during an AnimatedContainer transition.
        boxShadow: value
            ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 14)]
            : const [BoxShadow(color: Colors.transparent, blurRadius: 0)],
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x55000000), blurRadius: 5)],
          ),
        ),
      ),
    ),
  );
}

class GlassSegmentedControl<T> extends StatelessWidget {
  const GlassSegmentedControl({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final List<(T, String)> items;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.24),
      borderRadius: AppRadius.medium,
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        for (final item in items)
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(item.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: item.$1 == value
                      ? AppColors.highlight
                      : Colors.transparent,
                  borderRadius: AppRadius.small,
                ),
                child: Text(
                  item.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: item.$1 == value ? AppColors.text : AppColors.muted,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class PowerGauge extends StatelessWidget {
  const PowerGauge({
    super.key,
    required this.power,
    required this.active,
    this.max = 60,
  });

  final double power;
  final bool active;
  final double max;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 246,
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: active ? (power / max).clamp(0, 1) : 0),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => CustomPaint(
        painter: _GaugePainter(progress: value, active: active),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'OUTPUT POWER',
                  style: TextStyle(
                    color: AppColors.dim,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(active ? power : 0).toStringAsFixed(2)} W',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  active ? 'Output active' : 'Output off',
                  style: TextStyle(
                    color: active ? AppColors.green : AppColors.dim,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.progress, required this.active});
  final double progress;
  final bool active;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(18, 8, size.width - 36, size.width - 36);
    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      150 * 3.1415926535 / 180,
      240 * 3.1415926535 / 180,
      false,
      track,
    );
    final shader = const SweepGradient(
      startAngle: 2.5,
      endAngle: 6.7,
      colors: [AppColors.electricBlue, AppColors.cyan, AppColors.green],
    ).createShader(rect);
    final value = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawArc(
      rect,
      150 * 3.1415926535 / 180,
      240 * 3.1415926535 / 180 * progress,
      false,
      value..color = Colors.white.withValues(alpha: active ? 1 : 0.3),
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.active != active;
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
      ?action,
    ],
  );
}
