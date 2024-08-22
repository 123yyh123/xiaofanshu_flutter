import 'package:audioplayers/audioplayers.dart';

class AudioPlayManager {
  static AudioPlayManager? _instance;
  static AudioPlayer? _audioPlayer;

  // 获取单例实例
  static AudioPlayManager get instance => _instance ??= AudioPlayManager();

  // 获取 AudioPlayer 实例
  AudioPlayer get audioPlayer => _audioPlayer ??= AudioPlayer();

  AudioPlayManager();

  // 释放资源
  static void dispose() {
    _audioPlayer?.stop();
    _audioPlayer?.release();
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _instance = null;
  }
}
