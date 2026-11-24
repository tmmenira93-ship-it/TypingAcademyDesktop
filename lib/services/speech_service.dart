import 'dart:convert';
import 'dart:io';

/// Reads text aloud with the operating system's own voice (no plugin needed):
/// Windows SAPI through PowerShell, macOS `say`, Linux `spd-say` or `espeak`.
/// If no voice is installed the call is silent; it never throws.
class SpeechService {
  Process? _process;

  Future<void> speak(String text) async {
    await stop();
    final clean = text.trim();
    if (clean.isEmpty) {
      return;
    }
    try {
      if (Platform.isWindows) {
        final escaped = clean.replaceAll("'", "''");
        final script =
            "Add-Type -AssemblyName System.Speech; \$s = New-Object System.Speech.Synthesis.SpeechSynthesizer; \$s.Speak('$escaped')";
        final bytes = <int>[];
        for (final unit in script.codeUnits) {
          bytes
            ..add(unit & 0xFF)
            ..add(unit >> 8);
        }
        _process = await Process.start(
          'powershell',
          ['-NoProfile', '-NonInteractive', '-EncodedCommand', base64Encode(bytes)],
        );
      } else if (Platform.isMacOS) {
        _process = await Process.start('say', [clean]);
      } else if (Platform.isLinux) {
        try {
          _process = await Process.start('spd-say', ['-w', clean]);
        } catch (_) {
          _process = await Process.start('espeak', [clean]);
        }
      }
    } catch (_) {
      _process = null;
    }
  }

  Future<void> stop() async {
    final process = _process;
    _process = null;
    process?.kill();
  }
}
