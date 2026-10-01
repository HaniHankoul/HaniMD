import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

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
      TerminalLine('USER // SECURE CONSOLE v2.7.4', Color(0xff78f5c0)),
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
    chartValues: [],
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
    if (command == 'clear') {
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
              ' commands: scan  decrypt  trace  clear  chart  tree ',
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
    if (commandParts.first == 'tree') {
      _startTree();
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
    _timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
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

  void _startTree() {
    unawaited(_loadPhoneTree());
  }

  Future<void> _loadPhoneTree() async {
    _timer?.cancel();
    emit(
      state.copyWith(
        lines: [
          ...state.lines,
          const TerminalLine(
            'Resolving accessible phone storage paths ...',
            Color(0xff62d9ff),
          ),
        ],
        progress: 0.08,
        isRunning: true,
        lastCommand: 'tree',
      ),
    );

    final roots = <Directory>[];
    await _addRoot(roots, getApplicationDocumentsDirectory);
    await _addRoot(roots, getApplicationSupportDirectory);
    await _addRoot(roots, getTemporaryDirectory);
    if (Platform.isAndroid) {
      await _addRoot(roots, getExternalStorageDirectory);
    }

    final lines = <String>[];
    var directoryCount = 0;
    var fileCount = 0;
    if (roots.isEmpty) {
      lines.add('No accessible application directories were found.');
    } else {
      for (var index = 0; index < roots.length; index++) {
        final root = roots[index];
        lines.add(root.path);
        final counts = await _appendDirectoryContents(
          root,
          lines,
          prefix: '',
          depth: 0,
        );
        directoryCount += counts.directories;
        fileCount += counts.files;
        if (index != roots.length - 1) lines.add('');
      }
      lines.add('$directoryCount directories, $fileCount files');
    }

    if (isClosed) return;
    emit(
      state.copyWith(
        lines: [
          ...state.lines,
          ...lines.map((line) => TerminalLine(line, const Color(0xff62d9ff))),
        ],
        progress: 1,
        isRunning: false,
      ),
    );
  }

  Future<void> _addRoot(
    List<Directory> roots,
    Future<Directory?> Function() provider,
  ) async {
    try {
      final directory = await provider();
      if (directory == null) return;
      if (!roots.any((root) => root.path == directory.path)) {
        roots.add(directory);
      }
    } on Object {
      // Some platform directories are unavailable on specific targets.
    }
  }

  Future<_TreeCounts> _appendDirectoryContents(
    Directory directory,
    List<String> lines, {
    required String prefix,
    required int depth,
  }) async {
    if (depth >= 3) return const _TreeCounts();

    List<FileSystemEntity> children;
    try {
      children = await directory.list(followLinks: false).toList();
    } on Object {
      lines.add('$prefix└── [access denied]');
      return const _TreeCounts();
    }

    children.sort((left, right) {
      final leftIsDirectory = left is Directory;
      final rightIsDirectory = right is Directory;
      if (leftIsDirectory != rightIsDirectory) {
        return leftIsDirectory ? -1 : 1;
      }
      return left.path.toLowerCase().compareTo(right.path.toLowerCase());
    });

    var directoryCount = 0;
    var fileCount = 0;
    for (var index = 0; index < children.length; index++) {
      final child = children[index];
      final isLast = index == children.length - 1;
      final branch = isLast ? '└── ' : '├── ';
      final childPrefix = '$prefix${isLast ? '    ' : '│   '}';
      lines.add('$prefix$branch${_entityName(child)}');

      if (child is Directory) {
        directoryCount++;
        final nestedCounts = await _appendDirectoryContents(
          child,
          lines,
          prefix: childPrefix,
          depth: depth + 1,
        );
        directoryCount += nestedCounts.directories;
        fileCount += nestedCounts.files;
      } else {
        fileCount++;
      }
    }
    return _TreeCounts(directories: directoryCount, files: fileCount);
  }

  String _entityName(FileSystemEntity entity) {
    final parts = entity.path.split(RegExp(r'[\\/]'));
    return parts.lastWhere(
      (part) => part.isNotEmpty,
      orElse: () => entity.path,
    );
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
            'operator@user:~ % $command',
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

class _TreeCounts {
  const _TreeCounts({this.directories = 0, this.files = 0});

  final int directories;
  final int files;
}
