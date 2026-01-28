import 'package:audio_app_predict/classifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Classificação de Áudios',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Classificação de Áudios'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String start = "Iniciar captura de áudio";
  String stop = "Parar captura de áudio";

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderReady = false;
  bool _isRecording = false;

  String _resultadoClassificacao = "Fale algo...";
  Color _corResultado = Colors.grey;

  Future<void> initRecorder() async {
    await _recorder.openRecorder();
    _isRecorderReady = true;
    setState(() {});
  }

  Future<void> startRecording() async {
    // Limpa o resultado anterior ao iniciar nova gravação
    setState(() {
      _resultadoClassificacao = "Gravando...";
      _corResultado = Colors.blue;
    });

    var status = await Permission.microphone.request();

    if (status.isGranted) {
      if (!_isRecorderReady) return;
      await _recorder.startRecorder(
        toFile: 'audio_temp.pcm',
        codec: Codec.pcm16,
        sampleRate: 16000,
        numChannels: 1,
      );
      setState(() {
        _isRecording = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permissão de microfone negada. Não é possível gravar áudio.'),
        ),
      );

      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initRecorder();
  }

  Future<void> stopRecording() async {
    if (!_isRecorderReady) return;

    final path = await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });

    print("Áudio gravado em: $path");

    ClassifierAudio classificador = ClassifierAudio();
    final resultado = await classificador.classificarAudio(path.toString());

    if (resultado['erro'] != null) {
      setState(() {
        _resultadoClassificacao = "Erro: ${resultado['erro']}";
        _corResultado = Colors.red;
      });
      return;
    }

    final int maxIndex = resultado['maxIndex'];
    final double maxProb = resultado['maxProbabilidade'];
    final porcentagem = (maxProb * 100).toStringAsFixed(1);

    String palavra;
    Color cor;

    switch (maxIndex) {
      case 0: palavra = "Ruido"; cor = Colors.blueAccent; break;
      case 1: palavra = "Baixo"; cor = Colors.red; break;
      case 2: palavra = "Cima"; cor = Colors.orange; break;
      case 3: palavra = "Desligado"; cor = Colors.black; break;
      case 4: palavra = "Direita"; cor = Colors.deepOrange; break;
      case 5: palavra = "Esquerda"; cor = Colors.brown; break;
      case 6: palavra = "Ligado"; cor = Colors.deepPurple; break;
      default: palavra = "Ruido"; cor = Colors.blueAccent;
    }

    setState(() {
      _resultadoClassificacao = "$palavra ($porcentagem%)";
      _corResultado = cor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                _resultadoClassificacao,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _corResultado,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),

            FilledButton.icon(
              onPressed: () async {
                if (_isRecording) {
                  await stopRecording();
                } else {
                  await startRecording();
                }
              },
              label: Text(_isRecording ? stop : start),
              icon: const Icon(Icons.mic),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}