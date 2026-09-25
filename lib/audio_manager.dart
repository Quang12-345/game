import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  // Singleton pattern
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _player = AudioPlayer();

  /// 1. Phát nhạc nền Trang chủ (Lặp đi lặp lại)
  Future<void> playBgm() async {
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('audio/main music.mp3')); // Sử dụng file start.mp3 làm nhạc nền
    } catch (e) {
      debugPrint("Lỗi phát nhạc nền: $e");
    }
  }

  /// 2. Phát âm thanh đếm ngược / Bắt đầu đua
  Future<void> playStartSound() async {
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.release);
      await _player.play(AssetSource('audio/start.mp3'));
    } catch (e) {
      debugPrint("Lỗi phát âm thanh start: $e");
    }
  }

  /// 3. Phát âm thanh khi thắng cược
  Future<void> playWinSound() async {
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.release);
      await _player.play(AssetSource('audio/win.mp3'));
    } catch (e) {
      debugPrint("Lỗi phát âm thanh win: $e");
    }
  }

  /// 4. Phát âm thanh khi thua cược
  Future<void> playLoseSound() async {
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.release);
      await _player.play(AssetSource('audio/lose.mp3'));
    } catch (e) {
      debugPrint("Lỗi phát âm thanh lose: $e");
    }
  }

  /// 5. Dừng âm thanh
  Future<void> stopSound() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint("Lỗi dừng âm thanh: $e");
    }
  }
}