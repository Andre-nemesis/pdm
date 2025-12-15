import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Regressão Linear',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Regressão Linear'),
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

  double value1 = 1.0;

  final TextEditingController _regressionControler = TextEditingController();

  late Interpreter _interpreter;
  bool _isLoaded = false;
  double? predictResult = 0.0;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/linear_regression.tflite',);
      _isLoaded = true;
      print("Modelo carregado com sucesso!");
    } catch (e) {
      print("Erro ao carregar o modelo: $e");
    }
  }

  Future<double> predict(double inputValue) async {
    if (!_isLoaded) {
      await loadModel();
    }

    try {
      //Shape (1,1) =
      var input = [[inputValue]];
      var output = List.filled(1 * 1, 0.0).reshape([1, 1]);
      _interpreter.run(input, output);
      return output[0][0];
    } catch (e) {
      print('Erro na predição: $e');
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.title,
          style: TextStyle(
              color: Colors.black
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:.start,
          children: [
            const Text(
                "Escolha um valor para a regressao linear"
            ),
            SizedBox(height: 20,),
            Card(
                child:Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                          "Input Value: ${value1.toStringAsFixed(2)}"
                      ),
                      Slider(
                        value: value1,
                        max:100,
                        label: value1.toStringAsFixed(2),
                        onChanged: (double value) =>{
                          setState(() {
                            value1=value;
                          }
                          )
                        },
                      ),
                    ],
                  ),
                )
            ),
            SizedBox(height: 20,),
            FilledButton(
              onPressed: () async {
                final result = await predict(value1);
                setState(() {
                  predictResult = result;
                  print("$predictResult #################");
                });
              },
              style: ButtonStyle(padding: WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.all(20))),
              child: const Text("Estimar valor"),
            ),
            SizedBox(height: 20,),
            Card(
              child: Padding(
                padding:  EdgeInsets.all(10),
                child: Text(
                    'O valor predito é: $predictResult'
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
