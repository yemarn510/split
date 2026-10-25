import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'ant_icon_data.dart';

export 'ant_icon_data.dart';

/// Renders an `@ant-design/icons` glyph. Like `.anticon`, it defaults to the
/// surrounding text color, and spins when [spin] is set (`anticon-spin`).
class AntIcon extends StatelessWidget {
  final AntIconData icon;
  final double size;
  final Color? color;
  final bool spin;

  const AntIcon(
    this.icon, {
    super.key,
    this.size = 16,
    this.color,
    this.spin = false,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? DefaultTextStyle.of(context).style.color ?? Colors.black;
    final svg = SvgPicture.string(
      icon.svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(resolved, BlendMode.srcIn),
    );
    return spin ? _Spin(child: svg) : svg;
  }
}

/// `CheckCircleTwoTone` with a custom `twoToneColor`.
class AntTwoToneIcon extends StatelessWidget {
  final AntIconData icon;
  final double size;
  final Color primary;
  final Color secondary;

  const AntTwoToneIcon(
    this.icon, {
    super.key,
    this.size = 16,
    required this.primary,
    required this.secondary,
  });

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  @override
  Widget build(BuildContext context) {
    final svg = icon.svg
        .replaceAll('fill="#333"', 'fill="${_hex(primary)}"')
        .replaceAll('fill="#E6E6E6"', 'fill="${_hex(secondary)}"');
    return SvgPicture.string(svg, width: size, height: size);
  }
}

class _Spin extends StatefulWidget {
  final Widget child;
  const _Spin({required this.child});

  @override
  State<_Spin> createState() => _SpinState();
}

class _SpinState extends State<_Spin> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(turns: _controller, child: widget.child);
  }
}
