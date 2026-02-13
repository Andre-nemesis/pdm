// classifier.dart
// Este arquivo está preparado para integração do modelo TFLite
// Descomente e configure após treinar o modelo

/*
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:dart_bert_tokenizer/dart_bert_tokenizer.dart';

Interpreter? _interpreter;
WordPieceTokenizer? _tokenizer;

/// Carrega o modelo TFLite e o tokenizador BERT
/// Deve ser chamado antes de usar classifyWithTFLite
Future<void> loadModelAndTokenizer() async {
  if (_interpreter == null) {
    _interpreter = await Interpreter.fromAsset('assets/model.tflite');
    print('✅ Modelo TFLite carregado com sucesso');
  }
  
  if (_tokenizer == null) {
    final vocabText = await rootBundle.loadString('assets/vocab.txt');
    final vocabLines = vocabText.split('\n');
    final vocabList = vocabLines
        .map((line) => line.trim())
        .where((token) => token.isNotEmpty)
        .toList();
    final vocabulary = Vocabulary.fromTokens(vocabList);
    _tokenizer = WordPieceTokenizer(vocab: vocabulary);
    print('✅ Tokenizador carregado com sucesso');
  }
}

/// Classifica um texto como spam ou não-spam usando o modelo TFLite
/// 
/// Parâmetros:
///   - text: O texto a ser classificado
/// 
/// Retorna:
///   - true se o texto for spam
///   - false se o texto for legítimo
/// 
/// Exemplo de uso:
/// ```dart
/// final isSpam = await classifyWithTFLite('Você ganhou R$1000! Clique aqui!');
/// if (isSpam) {
///   print('⚠️ Spam detectado!');
/// } else {
///   print('✅ Mensagem segura');
/// }
/// ```
Future<bool> classifyWithTFLite(String text) async {
  await loadModelAndTokenizer();

  // Tokenizar o texto
  final encoding = _tokenizer!.encode(text);
  
  // Preparar inputs para o modelo
  // Ajuste max_length conforme foi usado no treinamento (geralmente 128)
  const maxLength = 128;
  
  // Preencher ou truncar para maxLength
  List<int> paddedIds = List.filled(maxLength, 0);
  List<int> paddedMask = List.filled(maxLength, 0);
  List<int> paddedTypeIds = List.filled(maxLength, 0);
  
  for (int i = 0; i < min(encoding.ids.length, maxLength); i++) {
    paddedIds[i] = encoding.ids[i];
    paddedMask[i] = 1; // 1 para tokens reais, 0 para padding
    paddedTypeIds[i] = encoding.typeIds?[i] ?? 0;
  }

  // Formatar para o modelo (batch_size = 1)
  final inputIds = [paddedIds];
  final attentionMask = [paddedMask];
  final tokenTypeIds = [paddedTypeIds];

  // Preparar output
  var output = List.generate(1, (_) => List.filled(2, 0.0)); // 2 classes: não-spam, spam
  final outputs = {0: output};

  // Executar inferência
  _interpreter!.runForMultipleInputs(
    [inputIds, attentionMask, tokenTypeIds],
    outputs,
  );

  // Obter probabilidades
  // output[0][0] = probabilidade de não-spam
  // output[0][1] = probabilidade de spam
  double spamProb = output[0][1];
  
  print('📊 Probabilidade de spam: ${(spamProb * 100).toStringAsFixed(2)}%');
  
  // Retorna true se probabilidade de spam > 50%
  return spamProb > 0.5;
}

/// Classifica múltiplas mensagens de uma vez
/// Útil para processar lotes de emails
Future<List<bool>> classifyBatch(List<String> texts) async {
  await loadModelAndTokenizer();
  
  List<bool> results = [];
  for (String text in texts) {
    final isSpam = await classifyWithTFLite(text);
    results.add(isSpam);
  }
  
  return results;
}

/// Obtém a probabilidade de spam (0.0 a 1.0) ao invés de apenas true/false
Future<double> getSpamProbability(String text) async {
  await loadModelAndTokenizer();

  final encoding = _tokenizer!.encode(text);
  const maxLength = 128;
  
  List<int> paddedIds = List.filled(maxLength, 0);
  List<int> paddedMask = List.filled(maxLength, 0);
  List<int> paddedTypeIds = List.filled(maxLength, 0);
  
  for (int i = 0; i < min(encoding.ids.length, maxLength); i++) {
    paddedIds[i] = encoding.ids[i];
    paddedMask[i] = 1;
    paddedTypeIds[i] = encoding.typeIds?[i] ?? 0;
  }

  final inputIds = [paddedIds];
  final attentionMask = [paddedMask];
  final tokenTypeIds = [paddedTypeIds];

  var output = List.generate(1, (_) => List.filled(2, 0.0));
  final outputs = {0: output};

  _interpreter!.runForMultipleInputs(
    [inputIds, attentionMask, tokenTypeIds],
    outputs,
  );

  return output[0][1]; // Retorna probabilidade de spam
}

/// Libera recursos do modelo e tokenizador
/// Chame quando não for mais usar o classificador
void dispose() {
  _interpreter?.close();
  _interpreter = null;
  _tokenizer = null;
  print('🗑️ Recursos do classificador liberados');
}
*/

// TODO: Após treinar o modelo:
// 1. Adicione model.tflite em assets/
// 2. Adicione vocab.txt em assets/
// 3. Atualize pubspec.yaml com:
//    flutter:
//      assets:
//        - assets/model.tflite
//        - assets/vocab.txt
// 4. Descomente todo este arquivo
// 5. Instale as dependências:
//    flutter pub add tflite_flutter
//    flutter pub add dart_bert_tokenizer
// 6. Descomente as chamadas nas telas (login_screen.dart, analysis_screen.dart)
