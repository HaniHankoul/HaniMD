import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../logic/home_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) => Scaffold(
        backgroundColor: const Color(0xff080d12),
        body: SafeArea(
          child: Row(
            children: [
              const _Rail(),
              Expanded(child: _TerminalPanel(state: state)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail();

  @override
  Widget build(BuildContext context) => Container(
    width: 82,
    color: const Color(0xff101a22),
    child: Column(
      children: [
        const SizedBox(height: 22),
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xff78f5c0).withValues(alpha: .12),
            border: Border.all(
              color: const Color(0xff78f5c0).withValues(alpha: .4),
            ),
          ),
          child: const Icon(Icons.bolt, color: Color(0xff78f5c0)),
        ),
        const SizedBox(height: 34),
        const _RailIcon(icon: Icons.terminal, active: true),
        _RailIcon(
          icon: Icons.speed_outlined,
          onTap: () => context.go('/speed-test'),
          tooltip: 'Internet speed test',
        ),
        const _RailIcon(icon: Icons.folder_open),
        const Spacer(),
        const _RailIcon(icon: Icons.settings_outlined),
        const SizedBox(height: 18),
      ],
    ),
  );
}

class _RailIcon extends StatelessWidget {
  const _RailIcon({
    required this.icon,
    this.active = false,
    this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final bool active;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(
        icon,
        color: active ? const Color(0xff78f5c0) : const Color(0xff52616d),
        size: 21,
      ),
    ),
  );
}

class _TerminalPanel extends StatefulWidget {
  const _TerminalPanel({required this.state});

  final HomeState state;

  @override
  State<_TerminalPanel> createState() => _TerminalPanelState();
}

class _TerminalPanelState extends State<_TerminalPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant _TerminalPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontFamily: 'monospace',
      fontSize: 13,
      height: 1.65,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'HaniMD',
                style: TextStyle(
                  color: Color(0xffe6edf3),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '/ LIVE CONSOLE',
                style: textStyle?.copyWith(
                  color: const Color(0xff52616d),
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              const Icon(Icons.circle, size: 8, color: Color(0xff78f5c0)),
              const SizedBox(width: 7),
              Text(
                'ONLINE',
                style: textStyle?.copyWith(
                  color: const Color(0xff78f5c0),
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ProgressBar(
            progress: widget.state.progress,
            isRunning: widget.state.isRunning,
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xff0c131a),
                border: Border.all(color: const Color(0xff1c2a34)),
              ),
              child: Column(
                children: [
                  if (widget.state.chartValues.isNotEmpty) ...[
                    _ChartCard(
                      values: widget.state.chartValues,
                      maxValue: widget.state.chartMax,
                    ),
                    const SizedBox(height: 14),
                  ],
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: widget.state.lines.length,
                      itemBuilder: (context, index) {
                        final line = widget.state.lines[index];
                        return Text(
                          line.text.isEmpty ? ' ' : line.text,
                          style: textStyle?.copyWith(
                            color: line.color,
                            fontWeight: line.isCommand
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            textDirection: TextDirection.ltr,
            controller: _controller,
            autofocus: true,
            style: textStyle?.copyWith(color: const Color(0xffe6edf3)),
            cursorColor: const Color(0xff78f5c0),
            decoration: InputDecoration(
              prefixText: 'operator@user:~ % ',
              prefixStyle: textStyle?.copyWith(color: const Color(0xff78f5c0)),
              hintText: 'enter directive',
              hintStyle: textStyle?.copyWith(color: const Color(0xff52616d)),
              filled: true,
              fillColor: const Color(0xff101a22),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff1c2a34)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff1c2a34)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff78f5c0)),
              ),
            ),
            onSubmitted: (value) {
              context.read<HomeCubit>().submit(value);
              _controller.clear();
            },
          ),
          const SizedBox(height: 9),
          Text(
            'INPUT READY  //  scan, decrypt, trace, tree, help  //  clr wipes the console',
            style: TextStyle(
              color: Color(0xff52616d),
              fontFamily: 'monospace',
              fontSize: 10,
              letterSpacing: .4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, required this.isRunning});

  final double progress;
  final bool isRunning;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            isRunning ? 'EXECUTING SEQUENCE' : 'SEQUENCE READY',
            style: const TextStyle(
              color: Color(0xff81909d),
              fontFamily: 'monospace',
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          Text(
            '${(progress * 100).round()}%',
            style: const TextStyle(
              color: Color(0xff78f5c0),
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
        ],
      ),
      const SizedBox(height: 7),
      LinearProgressIndicator(
        value: progress,
        minHeight: 5,
        backgroundColor: const Color(0xff1c2a34),
        color: const Color(0xff78f5c0),
      ),
    ],
  );
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.values, required this.maxValue});

  final List<double> values;
  final double maxValue;

  @override
  Widget build(BuildContext context) => Container(
    height: 188,
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
    decoration: BoxDecoration(
      color: const Color(0xff101a22),
      border: Border.all(color: const Color(0xff234037)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'SIGNAL / LIVE PLOT',
              style: TextStyle(
                color: Color(0xff78f5c0),
                fontFamily: 'monospace',
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Text(
              'MAX ${maxValue.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xff81909d),
                fontFamily: 'monospace',
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: CustomPaint(
            painter: _ChartPainter(values: values, maxValue: maxValue),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    ),
  );
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({required this.values, required this.maxValue});

  final List<double> values;
  final double maxValue;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xff234037)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = const Color(0xff78f5c0)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final glowPaint = Paint()
      ..color = const Color(0xff78f5c0).withValues(alpha: .12)
      ..style = PaintingStyle.fill;

    for (var row = 0; row <= 4; row++) {
      final y = size.height * row / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (var column = 0; column <= 6; column++) {
      final x = size.width * column / 6;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    if (values.length < 2 || maxValue <= 0) return;
    final points = <Offset>[];
    for (var index = 0; index < values.length; index++) {
      final x = size.width * index / (values.length - 1);
      final y = size.height - (values[index] / maxValue * size.height);
      points.add(Offset(x, y.clamp(0, size.height).toDouble()));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(fillPath, glowPaint);
    canvas.drawPath(linePath, linePaint);
    for (final point in points) {
      canvas.drawCircle(point, 2.8, linePaint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.maxValue != maxValue;
}
