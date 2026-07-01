import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  VoiceService._();
  static final VoiceService instance = VoiceService._();

  final FlutterTts _tts = FlutterTts();

  Future<void> initialize() async {
    if (Platform.isIOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.duckOthers,
      ]);
    }

    final isArabicAvailable = await _tts.isLanguageAvailable('ar');
    await _tts.setLanguage(isArabicAvailable ? 'ar' : 'en-US');

    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> pause() async {
    await _tts.pause();
  }

Future<void> dispose() async {
    await _tts.stop();
  }
}
