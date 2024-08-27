import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

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
    try {
      _audioPlayer?.stop();
      _audioPlayer?.release();
      _audioPlayer?.dispose();
    } catch (e) {
      Get.log('音频播放器关闭');
    }
    _audioPlayer = null;
    _instance = null;
  }
}
