// background_service.dart
import 'dart:async';
import 'package:workmanager/workmanager.dart';
import 'package:predict_span_app/Authentication.dart';
import 'package:predict_span_app/local_notification_service.dart';
// import 'package:predict_span_app/Classifier.dart'; // Descomentar quando o modelo estiver pronto

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print('🔄 Iniciando verificação de emails...');

      // Inicializar serviço de notificações
      await LocalNotificationService.initialize();

      // Fazer sign-in silencioso
      final account = await signInSilently();
      if (account == null) {
        print('❌ Falha no sign-in silencioso');
        return true;
      }

      print('✅ Login realizado: ${account.email}');

      // Obter API do Gmail
      final gmailApi = await getGmailApi(account);
      
      // Buscar emails não lidos
      final emails = await fetchNewEmails(gmailApi);
      print('📧 ${emails.length} emails não lidos encontrados');

      if (emails.isEmpty) {
        print('✅ Nenhum email novo para verificar');
        return true;
      }

      // Contador de spam detectado
      int spamCount = 0;
      
      // Verificar cada email
      for (var email in emails) {
        final body = getEmailBody(email);
        final subject = _getEmailSubject(email);
        final snippet = email.snippet ?? '';
        
        print('📝 Verificando: ${subject.isNotEmpty ? subject : snippet}');

        // TODO: Descomentar quando o modelo estiver pronto
        // final isSpam = await classifyWithTFLite(body);
        
        // TEMPORÁRIO: Simula detecção (remover após treinar o modelo)
        final isSpam = _simulateSpamDetection(body, subject);
        
        if (isSpam) {
          spamCount++;
          print('⚠️ SPAM detectado!');
          
          // Enviar notificação de spam
          await LocalNotificationService.showSpamNotification(
            emailSubject: subject,
            emailSnippet: snippet,
            emailId: email.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          );
        } else {
          print('✅ Email seguro');
        }
      }

      // Se múltiplos spams foram detectados, enviar notificação de resumo
      if (spamCount > 1) {
        await LocalNotificationService.showSpamSummaryNotification(
          spamCount: spamCount,
        );
      }

      print('✅ Verificação concluída. $spamCount spam(s) detectado(s)');
      
    } catch (e, stackTrace) {
      print('❌ Erro no background task: $e');
      print('Stack trace: $stackTrace');
    }
    
    return true;
  });
}

/// Extrai o assunto do email
String _getEmailSubject(dynamic message) {
  final headers = message.payload?.headers ?? [];
  for (var header in headers) {
    if (header.name?.toLowerCase() == 'subject') {
      return header.value ?? '';
    }
  }
  return '';
}

/// TEMPORÁRIO: Simula detecção de spam
/// Remover esta função após treinar o modelo real
bool _simulateSpamDetection(String body, String subject) {
  // Lista de palavras-chave típicas de spam
  final spamKeywords = [
    'ganhe',
    'grátis',
    'clique aqui',
    'urgente',
    'parabéns',
    'prêmio',
    'desconto',
    'oferta',
    'limited time',
    'act now',
    'winner',
    'congratulations',
    'free',
    'click here',
    'viagra',
    'casino',
    'lottery',
    '\$\$\$',
  ];

  final textToCheck = '${subject.toLowerCase()} ${body.toLowerCase()}';
  
  // Se encontrar 2 ou mais palavras-chave de spam, considera como spam
  int keywordCount = 0;
  for (var keyword in spamKeywords) {
    if (textToCheck.contains(keyword.toLowerCase())) {
      keywordCount++;
    }
  }
  
  return keywordCount >= 2;
}

/// Registra a tarefa periódica de verificação de emails
Future<void> registerEmailCheckTask() async {
  await Workmanager().registerPeriodicTask(
    'emailChecker',
    'emailCheckerTask',
    frequency: const Duration(minutes: 15), // Mínimo permitido
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
    inputData: {
      'description': 'Verifica novos emails e detecta spam',
    },
  );
  
  print('✅ Tarefa de verificação de email registrada');
}

/// Cancela a tarefa de verificação de emails
Future<void> cancelEmailCheckTask() async {
  await Workmanager().cancelByUniqueName('emailChecker');
  print('🛑 Tarefa de verificação de email cancelada');
}

/// Verifica o status da tarefa
Future<bool> isEmailCheckTaskActive() async {
  // WorkManager não tem API direta para isso, então retornamos true
  // Uma alternativa seria salvar o estado em SharedPreferences
  return true;
}
