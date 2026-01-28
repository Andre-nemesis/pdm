import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassifierAudio {
  late Interpreter _interpreter;
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/model_audio.tflite');
      _isModelLoaded = true;
      print("Modelo carregado com sucesso!");
      print("Input shape: ${_interpreter.getInputTensor(0).shape}");
      print("Output shape: ${_interpreter.getOutputTensor(0).shape}");
    } catch (e) {
      print("Erro ao carregar o modelo: $e");
    }
  }

  Future<Map<String, dynamic>> classificarAudio(String audioPath) async {
    if (!_isModelLoaded) {
      await loadModel();
    }

    final file = File(audioPath);
    if (!await file.exists() || await file.length() == 0) {
      print("Erro: Arquivo de áudio não encontrado ou vazio: $audioPath");
      return {
        'probabilidades': List.filled(7, 0.0),
        'maxProbabilidade': 0.0,
        'maxIndex': -1,
        'erro': 'Arquivo inválido'
      };
    }

    final pcmBytes = await file.readAsBytes();
    final numSamples = pcmBytes.length ~/ 2;

    print("Samples lidos do áudio: $numSamples (${(numSamples / 16000).toStringAsFixed(2)} segundos)");

    if (numSamples == 0) {
      return {
        'probabilidades': List.filled(7, 0.0),
        'maxProbabilidade': 0.0,
        'maxIndex': -1,
        'erro': 'Nenhum sample lido'
      };
    }

    final Float32List floatBuffer = Float32List(numSamples);
    final byteData = ByteData.sublistView(pcmBytes);

    for (int i = 0; i < numSamples; i++) {
      final sample = byteData.getInt16(i * 2, Endian.little);
      floatBuffer[i] = sample / 32768.0;
    }

    const int tamanhoEsperado = 44032;
    final Float32List inputBuffer = Float32List(tamanhoEsperado);

    for (int i = 0; i < tamanhoEsperado; i++) {
      inputBuffer[i] = (i < numSamples) ? floatBuffer[i] : 0.0;
    }

    final input = inputBuffer.reshape([1, tamanhoEsperado]);
    final output = List.filled(7, 0.0).reshape([1, 7]);

    try {
      _interpreter.run(input, output);
      final probabilidades = output[0] as List<double>;
      double maxProb = probabilidades[0];
      int maxIndex = 0;
      for (int i = 1; i < probabilidades.length; i++) {
        if (probabilidades[i] > maxProb) {
          maxProb = probabilidades[i];
          maxIndex = i;
        }
      }

      print("Probabilidades: $probabilidades");
      print("Classe predominante: $maxIndex com confiança ${(maxProb * 100).toStringAsFixed(1)}%");

      return {
        'probabilidades': probabilidades,
        'maxProbabilidade': maxProb,
        'maxIndex': maxIndex,
        'erro': null,
      };
    } catch (e) {
      print("Erro durante a inferência: $e");
      return {
        'probabilidades': List.filled(7, 0.0),
        'maxProbabilidade': 0.0,
        'maxIndex': -1,
        'erro': e.toString(),
      };
    }
  }
}