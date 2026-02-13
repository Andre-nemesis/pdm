// analysis_screen.dart
import 'package:flutter/material.dart';
import 'package:predict_span_app/BackgroundService.dart';
import 'package:predict_span_app/local_notification_service.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _checkNow() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Mostrar notificação de teste
      await LocalNotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: '🔍 Verificação Manual',
        body: 'Iniciando verificação de emails...',
      );

      // TODO: Descomentar quando o modelo estiver pronto
      // Importar o Authentication e classificador
      // final account = await signInSilently();
      // if (account != null) {
      //   final gmailApi = await getGmailApi(account);
      //   final emails = await fetchNewEmails(gmailApi);
      //   
      //   int spamCount = 0;
      //   for (var email in emails) {
      //     final body = getEmailBody(email);
      //     final isSpam = await classifyWithTFLite(body);
      //     if (isSpam) {
      //       spamCount++;
      //       await LocalNotificationService.showSpamNotification(
      //         emailSubject: _getEmailSubject(email),
      //         emailSnippet: email.snippet ?? '',
      //         emailId: email.id ?? '',
      //       );
      //     }
      //   }
      //   
      //   if (spamCount > 0) {
      //     await LocalNotificationService.showSpamSummaryNotification(
      //       spamCount: spamCount,
      //     );
      //   }
      // }

      // Aguardar 2 segundos para simular verificação
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Verificação concluída! (Modelo será implementado)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Erro ao verificar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao verificar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'SmartText IA',
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
              // Título
              const Text(
                'Análise em segundo plano',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              // Campo de texto
              const Text(
                'Texto',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Digite seu texto...',
                  hintStyle: const TextStyle(color: Colors.black26),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Icons.edit_outlined, color: Color(0xFF4285F4)),
                  ),
                ),
              ),
              const Spacer(),
              // Status da análise
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Análise em segundo plano ativada!\nSuas mensagens serão verificadas automaticamente a cada 15 minutos.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Informação sobre notificações
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.notifications_active, color: Color(0xFF1976D2)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Você receberá notificações locais quando spam for detectado.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Botão Verificar agora
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isAnalyzing ? null : _checkNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isAnalyzing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Verificar agora',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              // Botão Encerrar análise
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isAnalyzing ? null : () {
                    _showStopAnalysisDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE53935),
                    side: const BorderSide(color: Color(0xFFE53935)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Encerrar análise',
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

  void _showStopAnalysisDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Encerrar análise?'),
          content: const Text(
            'A análise automática de mensagens será desativada. Você pode reativá-la a qualquer momento.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                // Cancelar tarefa do WorkManager
                await cancelEmailCheckTask();
                
                // Cancelar todas as notificações pendentes
                await LocalNotificationService.cancelAllNotifications();
                
                if (context.mounted) {
                  Navigator.of(context).pop(); // Fechar dialog
                  Navigator.of(context).pushReplacementNamed('/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Análise encerrada'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
              ),
              child: const Text('Encerrar'),
            ),
          ],
        );
      },
    );
  }
}
