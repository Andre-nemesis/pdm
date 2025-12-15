import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Lista de Tarefas'),
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
  final TextEditingController _tarefaController = TextEditingController();
  final List<Map<String, dynamic>> _tarefas = [];

  void _adicionarTarefa() {
    final texto = _tarefaController.text.trim();
    if (texto.isNotEmpty) {
      setState(() {
        _tarefas.add({'texto': texto, 'concluida': false});
        _tarefaController.clear();
      });
    }
  }

  void _alternarConclusao(int index) {
    setState(() {
      _tarefas[index]['concluida'] = !_tarefas[index]['concluida'];
    });
  }

  void _removerTarefa(int index) {
    setState(() {
      _tarefas.removeAt(index);
    });
  }

  void _limparTodas() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar todas as tarefas?'),
        content: const Text('Esta ação removerá todas as tarefas da lista.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _tarefas.clear());
              Navigator.of(ctx).pop();
            },
            child: const Text('Limpar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _mostrarSobre() {
    showAboutDialog(
      context: context,
      applicationName: 'Lista de Tarefas',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.check_circle, size: 50),
      children: const [
        Text('Uma simples aplicação de lista de tarefas feita em Flutter.'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'limpar') {
                _limparTodas();
              } else if (value == 'sobre') {
                _mostrarSobre();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'limpar',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 10),
                    Text('Limpar todas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sobre',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 10),
                    Text('Sobre'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text(
                      'Nova Tarefa',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _tarefaController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Digite sua tarefa...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _adicionarTarefa,
                      child: const Text("Adicionar Tarefa"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Suas Tarefas:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _tarefas.isEmpty
                  ? const Center(
                child: Text(
                  "Nenhuma tarefa adicionada ainda.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _tarefas.length,
                itemBuilder: (context, index) {
                  final tarefa = _tarefas[index];
                  final bool concluida = tarefa['concluida'];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: IconButton(
                        icon: Icon(
                          Icons.description,
                          color: concluida
                              ? Colors.green
                              : Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () => _alternarConclusao(index),
                      ),
                      title: Text(
                        tarefa['texto'],
                        style: TextStyle(
                          decoration: concluida
                              ? TextDecoration.lineThrough
                              : null,
                          color: concluida ? Colors.grey : null,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removerTarefa(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tarefaController.dispose();
    super.dispose();
  }
}
