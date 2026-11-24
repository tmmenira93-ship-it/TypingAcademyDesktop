import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

/// Short key / error / success sounds. The sounds are synthesised here (no audio assets)
/// and written once to a temp folder. Every failure is swallowed: if the audio plugin is
/// not available on a platform the app simply stays silent.
class SoundService {
  static const int _rate = 22050;
  static const List<double> _noteFrequencies = [261.63, 293.66, 329.63, 349.23, 392.0, 440.0, 493.88, 523.25];

  final List<AudioPlayer> _players = <AudioPlayer>[];
  final Map<String, String> _files = <String, String>{};
  Future<void>? _init;
  bool _ready = false;
  int _next = 0;

  void click() => unawaited(_play('click'));
  void error() => unawaited(_play('error'));
  void success() => unawaited(_play('success'));

  /// A piano-like note of the C major scale (index 0..7).
  void note(int index) => unawaited(_play('note${index < 0 ? 0 : (index > 7 ? 7 : index)}'));

  Future<void> _ensureReady() {
    return _init ??= _setUp();
  }

  Future<void> _setUp() async {
    try {
      final dir = await Directory.systemTemp.createTemp('typing_academy_sounds_');
      _files['click'] = await _write(dir, 'click.wav', _tone(1800, 0.02, 0.45));
      _files['error'] = await _write(dir, 'error.wav', _tone(170, 0.14, 0.4, square: true));
      _files['success'] = await _write(dir, 'success.wav', [
        ..._tone(523, 0.09, 0.4),
        ..._tone(659, 0.09, 0.4),
        ..._tone(784, 0.16, 0.4),
      ]);
      for (var i = 0; i < _noteFrequencies.length; i++) {
        _files['note$i'] = await _write(dir, 'note$i.wav', _piano(_noteFrequencies[i], 0.7));
      }
      for (var i = 0; i < 4; i++) {
        final player = AudioPlayer();
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setVolume(0.6);
        _players.add(player);
      }
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  Future<void> _play(String name) async {
    try {
      await _ensureReady();
      final path = _files[name];
      if (!_ready || path == null) {
        return;
      }
      final player = _players[_next % _players.length];
      _next += 1;
      await player.play(DeviceFileSource(path));
    } catch (_) {
      // silent fallback
    }
  }

  Future<String> _write(Directory dir, String name, List<double> samples) async {
    final file = File('${dir.path}${Platform.pathSeparator}$name');
    await file.writeAsBytes(buildWav(samples));
    return file.path;
  }

  /// Mono 16-bit PCM WAV bytes for [samples] in the range -1..1.
  static Uint8List buildWav(List<double> samples, {int rate = _rate}) {
    final data = ByteData(44 + samples.length * 2);
    void ascii(int offset, String text) {
      for (var i = 0; i < text.length; i++) {
        data.setUint8(offset + i, text.codeUnitAt(i));
      }
    }

    ascii(0, 'RIFF');
    data.setUint32(4, 36 + samples.length * 2, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, 1, Endian.little);
    data.setUint32(24, rate, Endian.little);
    data.setUint32(28, rate * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    ascii(36, 'data');
    data.setUint32(40, samples.length * 2, Endian.little);
    for (var i = 0; i < samples.length; i++) {
      final value = (samples[i].clamp(-1.0, 1.0) * 32767).round();
      data.setInt16(44 + i * 2, value, Endian.little);
    }
    return data.buffer.asUint8List();
  }

  static List<double> _piano(double hz, double seconds) {
    final count = (seconds * _rate).round();
    return List<double>.generate(count, (i) {
      final t = i / _rate;
      final attack = math.min(1.0, t / 0.006);
      final body = math.exp(-5.0 * t);
      final wave = math.sin(2 * math.pi * hz * t) +
          0.5 * math.sin(2 * math.pi * hz * 2 * t) * math.exp(-8.0 * t) +
          0.25 * math.sin(2 * math.pi * hz * 3 * t) * math.exp(-11.0 * t);
      return wave * attack * body * 0.35;
    });
  }

  static List<double> _tone(double hz, double seconds, double volume, {bool square = false}) {
    final count = (seconds * _rate).round();
    return List<double>.generate(count, (i) {
      final t = i / _rate;
      final envelope = math.exp(-4.0 * i / count);
      final wave = math.sin(2 * math.pi * hz * t);
      return (square ? (wave >= 0 ? 1.0 : -1.0) : wave) * envelope * volume;
    });
  }
}
