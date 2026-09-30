import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TerminalLine {
  const TerminalLine(this.text, this.color, {this.isCommand = false});

  final String text;
  final Color color;
  final bool isCommand;
}

class HomeState {
  const HomeState({
    required this.lines,
    required this.progress,
    required this.isRunning,
    required this.lastCommand,
    required this.chartValues,
    required this.chartMax,
  });

  factory HomeState.initial() => const HomeState(
    lines: [
      TerminalLine('NEXUS // SECURE CONSOLE v2.7.4', Color(0xff78f5c0)),
      TerminalLine(
        'Connection established. Waiting for input...',
        Color(0xff81909d),
      ),
      TerminalLine('', Color(0xff81909d)),
      TerminalLine('Try: scan, decrypt, trace, or help', Color(0xffffc857)),
    ],
    progress: 0,
    isRunning: false,
    lastCommand: '',
    chartValues: const [],
    chartMax: 0,
  );

  final List<TerminalLine> lines;
  final double progress;
  final bool isRunning;
  final String lastCommand;
  final List<double> chartValues;
  final double chartMax;

  HomeState copyWith({
    List<TerminalLine>? lines,
    double? progress,
    bool? isRunning,
    String? lastCommand,
    List<double>? chartValues,
    double? chartMax,
  }) {
    return HomeState(
      lines: lines ?? this.lines,
      progress: progress ?? this.progress,
      isRunning: isRunning ?? this.isRunning,
      lastCommand: lastCommand ?? this.lastCommand,
      chartValues: chartValues ?? this.chartValues,
      chartMax: chartMax ?? this.chartMax,
    );
  }
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState.initial());

  Timer? _timer;
  final Random _random = Random();

  static const _commands = {
    'scan': [
      'Scanning subnet 10.42.0.0/16 ...',
      'Found 12 active nodes / 03 encrypted channels',
      'Mapping exposed ports: 22, 443, 8080',
      'Reading handshake signatures from exposed services ...',
      'Cross-checking node fingerprints against the shadow index',
      'Signal integrity confirmed at 98.7%',
      'Payload route calculated. No alarms triggered.',
    ],
    'decrypt': [
      'Loading shard keys from /vault/echo ...',
      'Brute force matrix synchronized',
      'Rotating cipher lattice: AES-256 -> unlocked',
      'Rebuilding fragmented metadata blocks',
      'Verifying checksum against the original archive',
      'Access layer bypass complete',
      'Archive decrypted. Extracting signal...',
    ],
    'trace': [
      'Following packet ghost through relay 07 ...',
      'Relay hop 01: 172.16.4.18',
      'Relay hop 02: 10.0.0.77',
      'Obfuscation layer detected: spectral route',
      'Mirroring trace packets through a decoy channel',
      'Origin confidence raised to 91%',
      'Source located behind a silent gateway.',
    ],
  };

  void submit(String rawCommand) {
    final command = rawCommand.trim().toLowerCase();
    if (command.isEmpty || state.isRunning) return;
    if (command == 'clear' || command == 'clr') {
      emit(HomeState.initial().copyWith(lines: const []));
      return;
    }
    _appendCommand(command);
    if (command == 'help') {
      emit(
        state.copyWith(
          lines: [
            ...state.lines,
            const TerminalLine(
              'Available commands: scan  decrypt  trace  clear  clr',
              Color(0xffffc857),
            ),
          ],
          lastCommand: command,
        ),
      );
      return;
    }
    final commandParts = command.split(RegExp(r'\s+'));
    if (commandParts.first == 'chart') {
      _startChart(commandParts);
      return;
    }
    final output =
        _commands[command] ??
        [
          'Unknown directive. Searching suggestion index ...',
          'Try one of: scan, decrypt, trace, help',
        ];
    _timer?.cancel();
    var step = 0;
    emit(state.copyWith(progress: 0.04, isRunning: true, lastCommand: command));
    _timer = Timer.periodic(const Duration(milliseconds: 520), (timer) {
      if (step >= output.length) {
        timer.cancel();
        emit(state.copyWith(progress: 1, isRunning: false));
        return;
      }
      final color = [
        const Color(0xff62d9ff),
        const Color(0xffffc857),
        const Color(0xffd39cff),
      ][_random.nextInt(3)];
      step++;
      emit(
        state.copyWith(
          lines: [...state.lines, TerminalLine(output[step - 1], color)],
          progress: step / output.length,
        ),
      );
    });
  }

  void _startChart(List<String> commandParts) {
    final maxValue = commandParts.length == 2
        ? double.tryParse(commandParts[1])
        : null;
    if (maxValue == null || !maxValue.isFinite || maxValue <= 0) {
      emit(
        state.copyWith(
          lines: [
            ...state.lines,
            const TerminalLine(
              'Usage: chart <positive number>  e.g. chart 4',
              Color(0xffffc857),
            ),
          ],
          lastCommand: 'chart',
        ),
      );
      return;
    }

    final values = List<double>.generate(
      14,
      (_) => _random.nextDouble() * maxValue,
    );
    final output = [
      'Generating waveform with upper bound ${maxValue.toStringAsFixed(2)} ...',
      'Sampling ${values.length} points from the signal field',
      'Normalizing values between 0.00 and ${maxValue.toStringAsFixed(2)}',
      'Chart render complete. Signal looks remarkably stable.',
    ];
    _timer?.cancel();
    var step = 0;
    emit(
      state.copyWith(
        chartValues: values,
        chartMax: maxValue,
        progress: 0.04,
        isRunning: true,
      ),
    );
    _timer = Timer.periodic(const Duration(milliseconds: 520), (timer) {
      if (step >= output.length) {
        timer.cancel();
        emit(state.copyWith(progress: 1, isRunning: false));
        return;
      }
      step++;
      emit(
        state.copyWith(
          lines: [
            ...state.lines,
            TerminalLine(output[step - 1], const Color(0xff62d9ff)),
          ],
          progress: step / output.length,
        ),
      );
    });
  }

  void _appendCommand(String command) {
    emit(
      state.copyWith(
        lines: [
          ...state.lines,
          TerminalLine(
            'operator@ nexus:~ % $command',
            const Color(0xff78f5c0),
            isCommand: true,
          ),
        ],
        chartValues: const [],
        chartMax: 0,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
