import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calculadora de IMC'),
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

  final TextEditingController input1 = TextEditingController(text: "Informe seu Peso");
  final TextEditingController input2 = TextEditingController(text: "Informe sua Altura");
  Text txtIMC = Text("");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title,style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Column(
                children: [
                  TextField(
                    textAlign: TextAlign.center,
                    autocorrect: true,
                    controller: input1,
                    decoration: InputDecoration(
                        fillColor: Colors.orangeAccent
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    textAlign: TextAlign.center,
                    autocorrect: true,
                    controller: input2,
                    decoration: InputDecoration(
                        fillColor: Colors.orangeAccent
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        if(input1.text.isEmpty||input2.text.isEmpty){
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text("Informe um valor de peso e altura!"),
                              );
                            },
                          );
                        }else{
                          var pesoValue = double.parse(input1.text);
                          var alturaValue = double.parse(input2.text);
                          var imc = pesoValue / (alturaValue*alturaValue);
                          var imcText = "Seu IMC e: $imc" ;
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text(imcText),
                              );
                            },
                          );
                        }

                      },
                      child: Text("Calcular"),
                  )
                ],
              ),
            ),
            SizedBox(height: 100,),
            Card(
              child:
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("Seu IMC eh"),
                    txtIMC,
                    Text("Obesidade Grau 1")
                  ],
                ),
              ),
            ),
            Spacer(),
            Card(

              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                    "IMC = Peso(kg) ÷ Altura(m)²",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}
