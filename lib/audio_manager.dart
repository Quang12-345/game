import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  /// 1. Phát nhạc nền Trang chủ (Lặp đi lặp lại)
  Future<void> playBgm() async {
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      if (_bgmPlayer.state != PlayerState.playing) {
        await _bgmPlayer.play(AssetSource('audio/main music.mp3'));
      }
    } catch (e) {
      debugPrint("Lỗi phát nhạc nền: $e");
    }
  }

  /// 2. Phát âm thanh đếm ngược / Bắt đầu đua
  Future<void> playStartSound() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setReleaseMode(ReleaseMode.release);
      await _sfxPlayer.play(AssetSource('audio/start.mp3'));
    } catch (e) {
      debugPrint("Lỗi phát âm thanh start: $e");
    }
  }

  /// 3. Phát âm thanh khi thắng cược
  Future<void> playWinSound() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setReleaseMode(ReleaseMode.release);
      await _sfxPlayer.play(AssetSource('audio/win.mp3'));
    } catch (e) {
      debugPrint("Lỗi phát âm thanh win: $e");
    }
  }

  /// 4. Phát âm thanh khi thua cược
  Future<void> playLoseSound() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setReleaseMode(ReleaseMode.release);
      await _sfxPlayer.play(AssetSource('audio/lose.mp3'));
    } catch (e) {
      debugPrint("Lỗi phát âm thanh lose: $e");
    }
  }

  /// 5. Dừng tất cả âm thanh
  Future<void> stopSound() async {
    try {
      await _bgmPlayer.stop();
      await _sfxPlayer.stop();
    } catch (e) {
      debugPrint("Lỗi dừng âm thanh: $e");
    }
  }
}