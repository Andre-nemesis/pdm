// classifier.dart
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';

class SpamClassifier {
  static Interpreter? _interpreter;
  static bool _initialized = false;

  /// Inicializa o modelo (chamar uma vez)
  static Future<void> initialize() async {
    if (_initialized) return;

    _interpreter = await Interpreter.fromAsset(
      'email_spam_classifier.tflite',
      options: InterpreterOptions()
        ..threads = 2
        ..useNnApiForAndroid = true,
    );

    _initialized = true;
    print('✅ Classificador TFLite carregado');
  }

  /// Classifica um texto
  /// Retorna true = SPAM | false = HAM
  static Future<bool> getProbability(String text) async {
    await initialize();

    // 🔹 Modelo espera batch de strings
    final input = <String>[text];

    // 🔹 Saída: [[prob]]
    final output = List.generate(1, (_) => List.filled(1, 0.0));

    _interpreter!.run(input, output);

    final double probability = output[0][0];

    print('📊 Probabilidade de spam: $probability');

    return probability >= 0.5;
  }

  /// Retorna apenas a probabilidade (0.0 → 1.0)
  static Future<double> spamProbability(String text) async {
    await initialize();

    final input = <String>[text];
    final output = List.generate(1, (_) => List.filled(1, 0.0));

    _interpreter!.run(input, output);

    return output[0][0];
  }

  /// Libera recursos (opcional)
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _initialized = false;
    print('🗑️ Classificador finalizado');
  }
}