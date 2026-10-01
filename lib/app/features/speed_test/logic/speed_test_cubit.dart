import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

enum SpeedTestPhase { idle, download, upload, complete, error }

class SpeedTestState {
  const SpeedTestState({
    required this.phase,
    required this.progress,
    required this.downloadMbps,
    required this.uploadMbps,
    required this.errorMessage,
  });

  const SpeedTestState.initial()
    : phase = SpeedTestPhase.idle,
      progress = 0,
      downloadMbps = 0,
      uploadMbps = 0,
      errorMessage = null;

  final SpeedTestPhase phase;
  final double progress;
  final double downloadMbps;
  final double uploadMbps;
  final String? errorMessage;

  bool get isRunning =>
      phase == SpeedTestPhase.download || phase == SpeedTestPhase.upload;

  SpeedTestState copyWith({
    SpeedTestPhase? phase,
    double? progress,
    double? downloadMbps,
    double? uploadMbps,
    String? errorMessage,
  }) {
    return SpeedTestState(
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
      downloadMbps: downloadMbps ?? this.downloadMbps,
      uploadMbps: uploadMbps ?? this.uploadMbps,
      errorMessage: errorMessage,
    );
  }
}

class SpeedTestCubit extends Cubit<SpeedTestState> {
  SpeedTestCubit() : super(const SpeedTestState.initial());

  static final _downloadUrl = Uri.parse(
    'https://speed.cloudflare.com/__down?bytes=5000000',
  );
  static final _uploadUrl = Uri.parse('https://speed.cloudflare.com/__up');

  Future<void> runTest() async {
    if (state.isRunning) return;

    final client = http.Client();
    try {
      emit(
        state.copyWith(
          phase: SpeedTestPhase.download,
          progress: 0,
          downloadMbps: 0,
          uploadMbps: 0,
          errorMessage: null,
        ),
      );
      final downloadMbps = await _measureDownload(client);
      emit(
        state.copyWith(
          phase: SpeedTestPhase.upload,
          progress: 0,
          downloadMbps: downloadMbps,
        ),
      );
      final uploadMbps = await _measureUpload(client);
      emit(
        state.copyWith(
          phase: SpeedTestPhase.complete,
          progress: 1,
          downloadMbps: downloadMbps,
          uploadMbps: uploadMbps,
        ),
      );
    } on Object catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            phase: SpeedTestPhase.error,
            progress: 0,
            errorMessage: 'Test could not be completed: $error',
          ),
        );
      }
    } finally {
      client.close();
    }
  }

  Future<double> _measureDownload(http.Client client) async {
    final stopwatch = Stopwatch()..start();
    final response = await client.send(http.Request('GET', _downloadUrl));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Download server returned ${response.statusCode}.');
    }

    var received = 0;
    await for (final chunk in response.stream) {
      received += chunk.length;
      if (!isClosed) {
        emit(state.copyWith(progress: (received / 5000000).clamp(0, 1)));
      }
    }
    stopwatch.stop();
    return _megabitsPerSecond(received, stopwatch.elapsed);
  }

  Future<double> _measureUpload(http.Client client) async {
    final payload = Uint8List(2000000);
    final request = http.Request('POST', _uploadUrl)
      ..bodyBytes = payload
      ..headers['Content-Type'] = 'application/octet-stream';
    final stopwatch = Stopwatch()..start();
    final response = await client.send(request);
    await response.stream.drain();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Upload server returned ${response.statusCode}.');
    }
    stopwatch.stop();
    if (!isClosed) emit(state.copyWith(progress: 1));
    return _megabitsPerSecond(payload.length, stopwatch.elapsed);
  }

  double _megabitsPerSecond(int bytes, Duration elapsed) {
    final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    if (seconds <= 0) return 0;
    return bytes * 8 / seconds / 1000000;
  }
}
