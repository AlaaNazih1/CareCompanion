import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  static final _stt = SpeechToText();
  static final _tts = FlutterTts();
  static bool _isListening = false;

  static Future<void> initTts() async {
    await _tts.setLanguage('ar-EG');
    await _tts.setSpeechRate(0.5);   
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  static Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  static Future<void> stopSpeaking() => _tts.stop();

  static Future<bool> startListening({
    required Function(String text) onResult,
    Function()? onDone,
  }) async {
    final available = await _stt.initialize(
      onError: (_) => _isListening = false,
    );

    if (!available) return false;

    _isListening = true;
    await _stt.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
          _isListening = false;
          onDone?.call();
        }
      },
      localeId:        'ar_EG',
      listenFor:        const Duration(seconds: 10),
      pauseFor:         const Duration(seconds: 3),
      cancelOnError:    true,
    );

    return true;
  }

  static Future<void> stopListening() async {
    _isListening = false;
    await _stt.stop();
  }

  static bool get isListening => _isListening;

  static VoiceCommand parseCommand(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('طوارئ') || lower.contains('نجدة')) {
      return VoiceCommand.emergency;
    }
    if (lower.contains('دواء') || lower.contains('دوا')) {
      return VoiceCommand.medication;
    }
    if (lower.contains('اتصل') || lower.contains('ابني')) {
      return VoiceCommand.callCaregiver;
    }
    if (lower.contains('موقع') || lower.contains('مكاني')) {
      return VoiceCommand.location;
    }

    return VoiceCommand.unknown;
  }
}

enum VoiceCommand {
  emergency,
  medication,
  callCaregiver,
  location,
  unknown,
}