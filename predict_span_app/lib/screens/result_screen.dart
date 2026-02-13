// result_screen.dart
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String text;
  final bool isSpam;

  const ResultScreen({
    super.key,
    required this.text,
    required this.isSpam,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Resultado da Análise',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Ícone de resultado
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: isSpam 
                        ? const Color(0xFFFFEBEE) 
                        : const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSpam ? Icons.warning_rounded : Icons.check_circle_rounded,
                    size: 60,
                    color: isSpam 
                        ? const Color(0xFFE53935) 
                        : const Color(0xFF4CAF50),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Título do resultado
              Center(
                child: Text(
                  isSpam ? 'Spam Detectado!' : 'Mensagem Segura',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isSpam 
                        ? const Color(0xFFE53935) 
                        : const Color(0xFF4CAF50),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Descrição
              Center(
                child: Text(
                  isSpam 
                      ? 'Esta mensagem foi classificada como spam ou conteúdo indesejado.'
                      : 'Esta mensagem parece ser legítima e segura.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Card com o texto analisado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Texto analisado:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Informações adicionais
              if (isSpam)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFF9800)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Color(0xFFFF9800)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Evite clicar em links ou fornecer informações pessoais.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              // Botão de voltar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Analisar outra mensagem',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
