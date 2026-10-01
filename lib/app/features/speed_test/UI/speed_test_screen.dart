import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../logic/speed_test_cubit.dart';

class SpeedTestScreen extends StatelessWidget {
  const SpeedTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpeedTestCubit, SpeedTestState>(
      builder: (context, state) => Scaffold(
        backgroundColor: const Color(0xff071012),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.go('/'),
            tooltip: 'Back to console',
            icon: const Icon(Icons.arrow_back, color: Color(0xffd9f5ed)),
          ),
          title: const Text(
            'NETWORK // SPEED TEST',
            style: TextStyle(
              color: Color(0xffd9f5ed),
              fontFamily: 'monospace',
              fontSize: 14,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: [
                    const _StatusHeader(),
                    const SizedBox(height: 28),
                    _SpeedGauge(
                      value: state.phase == SpeedTestPhase.download
                          ? state.progress
                          : state.phase == SpeedTestPhase.upload
                          ? .5 + state.progress / 2
                          : state.phase == SpeedTestPhase.complete
                          ? 1
                          : 0,
                      valueLabel: _mainValue(state),
                      unitLabel: _mainUnit(state),
                    ),
                    const SizedBox(height: 26),
                    _PhaseLabel(state: state),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.download_rounded,
                            label: 'DOWNLOAD',
                            value: state.downloadMbps,
                            color: const Color(0xff55d6be),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.upload_rounded,
                            label: 'UPLOAD',
                            value: state.uploadMbps,
                            color: const Color(0xffffc857),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (state.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          state.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xffff8c7a),
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: state.isRunning
                            ? null
                            : () => context.read<SpeedTestCubit>().runTest(),
                        icon: Icon(
                          state.isRunning
                              ? Icons.sync_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(
                          state.isRunning ? 'TESTING...' : 'START TEST',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xff55d6be),
                          foregroundColor: const Color(0xff071012),
                          disabledBackgroundColor: const Color(0xff1d3b38),
                          disabledForegroundColor: const Color(0xff70958d),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'MEASUREMENTS USE A 5 MB DOWNLOAD AND 2 MB UPLOAD SAMPLE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xff526b6a),
                        fontFamily: 'monospace',
                        fontSize: 9,
                        letterSpacing: .5,
                      ),
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

  String _mainValue(SpeedTestState state) {
    if (state.phase == SpeedTestPhase.upload) {
      return state.uploadMbps.toStringAsFixed(2);
    }
    if (state.phase == SpeedTestPhase.complete) {
      return state.downloadMbps.toStringAsFixed(2);
    }
    if (state.phase == SpeedTestPhase.download) return '...';
    return state.downloadMbps > 0
        ? state.downloadMbps.toStringAsFixed(2)
        : '--';
  }

  String _mainUnit(SpeedTestState state) {
    if (state.phase == SpeedTestPhase.upload) return 'UPLOAD MBPS';
    return 'DOWNLOAD MBPS';
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader();

  @override
  Widget build(BuildContext context) => const Column(
    children: [
      Text(
        'CONNECTION DIAGNOSTICS',
        style: TextStyle(
          color: Color(0xff55d6be),
          fontFamily: 'monospace',
          fontSize: 11,
          letterSpacing: 2,
        ),
      ),
      SizedBox(height: 8),
      Text(
        'Check the pulse of your network',
        style: TextStyle(color: Color(0xff91aaa7), fontSize: 15),
      ),
    ],
  );
}

class _PhaseLabel extends StatelessWidget {
  const _PhaseLabel({required this.state});

  final SpeedTestState state;

  @override
  Widget build(BuildContext context) {
    final label = switch (state.phase) {
      SpeedTestPhase.download => 'DOWNLINK ANALYSIS IN PROGRESS',
      SpeedTestPhase.upload => 'UPLINK ANALYSIS IN PROGRESS',
      SpeedTestPhase.complete => 'ANALYSIS COMPLETE',
      SpeedTestPhase.error => 'ANALYSIS INTERRUPTED',
      SpeedTestPhase.idle => 'READY TO MEASURE',
    };
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xff91aaa7),
        fontFamily: 'monospace',
        fontSize: 10,
        letterSpacing: 1,
      ),
    );
  }
}

class _SpeedGauge extends StatelessWidget {
  const _SpeedGauge({
    required this.value,
    required this.valueLabel,
    required this.unitLabel,
  });

  final double value;
  final String valueLabel;
  final String unitLabel;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 300,
    height: 190,
    child: CustomPaint(
      painter: _GaugePainter(value: value),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            valueLabel,
            style: const TextStyle(
              color: Color(0xffd9f5ed),
              fontFamily: 'monospace',
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unitLabel,
            style: const TextStyle(
              color: Color(0xff55d6be),
              fontFamily: 'monospace',
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    ),
  );
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.value});

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 8);
    final radius = size.width * .39;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..color = const Color(0xff203634)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    final progress = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xff55d6be), Color(0xffffc857)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, track);
    canvas.drawArc(rect, math.pi, math.pi * value.clamp(0, 1), false, progress);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) => oldDelegate.value != value;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xff0d1b1d),
      border: Border.all(color: const Color(0xff1d3534)),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xff77918d),
                  fontFamily: 'monospace',
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value == 0 ? '--' : '${value.toStringAsFixed(2)} Mbps',
                style: TextStyle(
                  color: color,
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
