import 'dart:async';
import 'dart:developer';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';

class TranscriptionService {
  static final TranscriptionService _instance = TranscriptionService._internal();
  factory TranscriptionService() => _instance;
  TranscriptionService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  bool _shouldBeListening = false;

  final StreamController<String> _textController = StreamController.broadcast();
  Stream<String> get textStream => _textController.stream;

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;

  Future<void> initialize() async {
    try {
      _isAvailable = await _speech.initialize(
        onStatus: (status) => log('STT Status: $status'),
        onError: (error) => log('STT Error: $error'),
        debugLogging: true,
      );
      log('TranscriptionService initialized. Available: $_isAvailable');
    } catch (e) {
      log('Error initializing TranscriptionService: $e');
      _isAvailable = false;
    }
  }

  Timer? _restartTimer;
  int _retryCount = 0;

  Future<void> startListening() async {
    // Cancel any pending restart
    _restartTimer?.cancel();
    
    if (!_isAvailable) {
        await initialize();
        if (!_isAvailable) return;
    }

    if (_isListening) return;

    try {
      // Setup status listener for auto-restart
      _speech.statusListener = (status) {
        log('STT Status: $status');
        if (status == 'done' || status == 'notListening') {
           _isListening = false;
           // Auto-restart if we intend to be listening
           if (_shouldBeListening) {
             _scheduleRestart();
           }
        }
      };
      
      _speech.errorListener = (error) {
        log('STT Error: ${error.errorMsg} - ${error.permanent}');
        _isListening = false;
        if (_shouldBeListening) {
             // If error is "busy" (8) or "no match" (7), wait longer
             int delay = 2; 
             if (error.errorMsg.contains('busy') || error.errorMsg.contains('error_busy')) delay = 5;
             if (error.errorMsg.contains('7') || error.errorMsg.contains('match')) delay = 5;
             _scheduleRestart(delaySeconds: delay);
        }
      };

      await _speech.listen(
        onResult: _onSpeechResult,
        localeId: 'en_US', 
        listenFor: const Duration(seconds: 30), 
        pauseFor: const Duration(seconds: 5),
        listenOptions: stt.SpeechListenOptions(
            partialResults: true,
            cancelOnError: false, 
            listenMode: stt.ListenMode.dictation
        ),
      );
      _isListening = true;
      _shouldBeListening = true;
      _retryCount = 0; // Reset retry count on success
    } catch (e) {
      log('Error starting STT: $e');
      _isListening = false;
      if (_shouldBeListening) {
         _scheduleRestart(delaySeconds: 3);
      }
    }
  }

  void _scheduleRestart({int delaySeconds = 2}) {
     if (_restartTimer?.isActive ?? false) return;
     
     // Exponential backoff if failing repeatedly
     _retryCount++;
     int backoff = delaySeconds;
     if (_retryCount > 3) backoff = 5;
     if (_retryCount > 5) backoff = 10;

     log("Scheduling STT restart in $backoff seconds (Attempt $_retryCount)");
     
     _restartTimer = Timer(Duration(seconds: backoff), () {
        if (_shouldBeListening) {
           startListening();
        }
     });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult || result.alternates.isNotEmpty) {
      _textController.add(result.recognizedWords);
    }
  }

  Future<void> stopListening() async {
    _shouldBeListening = false;
    _restartTimer?.cancel();
    if (!_isListening) return;
    await _speech.stop();
    _isListening = false;
  }

  void dispose() {
    _restartTimer?.cancel();
    _textController.close();
  }
}

