import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final _player = AudioPlayer();

  static Future<void> tap() async {
    await _player.play(AssetSource('audio/tap.mp3'));
  }

  static Future<void> clear() async {
    await _player.play(AssetSource('audio/clear.mp3'));
  }
}
