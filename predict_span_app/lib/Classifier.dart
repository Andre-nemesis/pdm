// classifier.dart
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:dart_bert_tokenizer/dart_bert_tokenizer.dart';

Interpreter? _interpreter;
WordPieceTokenizer? _tokenizer;

Future<void> loadModelAndTokenizer() async {
  if (_interpreter == null) {
    _interpreter = await Interpreter.fromAsset('assets/model.tflite');
  }
  if (_tokenizer == null) {
    final vocabText = await rootBundle.loadString('assets/vocab.txt');
    final vocabLines = vocabText.split('\n');
    final vocabList = vocabLines.map((line) => line.trim()).where((token) => token.isNotEmpty).toList();
    final vocabulary = Vocabulary.fromTokens(vocabList);
    _tokenizer = WordPieceTokenizer(vocab: vocabulary);
  }
}

Future<bool> classifyWithTFLite(String text) async {
  await loadModelAndTokenizer();

  // Assuming encode handles addSpecialTokens, maxLength, padding, truncation
  // Adjust parameters if the package supports them; based on API, encode(text) defaults appropriately
  final encoding = _tokenizer!.encode(text); // Add params if available, e.g., maxLength: 128, padToMaxLength: true, truncate: true

  final inputIds = [encoding.ids];
  final attentionMask = [List<int>.generate(encoding.ids.length, (i) => encoding.ids[i] != 0 ? 1 : 0)]; // Derive mask if not provided
  final tokenTypeIds = [encoding.typeIds ?? List.filled(encoding.ids.length, 0)];

  var output = List.generate(1, (_) => List.filled(1, 0.0));

  _interpreter!.runForMultipleInputs([inputIds, attentionMask, tokenTypeIds], output as Map<int, Object>);

  double spamProb = output[0][0];
  return spamProb > 0.5;
}