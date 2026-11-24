import 'package:flutter_test/flutter_test.dart';
import 'package:typing_academy_desktop/services/sound_service.dart';

void main() {
  test('buildWav writes a valid PCM header', () {
    final bytes = SoundService.buildWav(List<double>.filled(100, 0.5));
    expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
    expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WAVE');
    expect(bytes.length, 44 + 200);
  });
}
