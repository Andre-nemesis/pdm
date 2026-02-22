import 'dart:async';
import 'package:workmanager/workmanager.dart';
import 'package:predict_span_app/Authentication.dart';
import 'package:predict_span_app/local_notification_service.dart';
import 'package:predict_span_app/Classifier.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print('🔄 Background email check iniciado');

      await LocalNotificationService.initialize();

      final account = await signInSilently();
      if (account == null) {
        print('❌ Não autenticado (background)');
        return true;
      }

      final gmailApi = await getGmailApi(account);
      final emails = await fetchNewEmails(gmailApi);

      int spamCount = 0;

      for (final email in emails) {
        final subject = _getSubject(email);
        final body = getEmailBody(email);

        final isSpam = await SpamClassifier.getProbability(body);

        if (isSpam) {
          spamCount++;

          await LocalNotificationService.showSpamNotification(
            emailSubject: subject,
            emailSnippet: email.snippet ?? '', emailId: '',
          );
        }
      }

      if (spamCount > 1) {
        await LocalNotificationService.showSpamSummaryNotification(
          spamCount: spamCount,
        );
      }

      print('✅ Background finalizado: $spamCount spam(s)');
    } catch (e, s) {
      print('❌ Erro no background: $e');
      print(s);
    }

    return true;
  });
}

/// Extrai assunto
String _getSubject(dynamic message) {
  final headers = message.payload?.headers ?? [];
  for (final h in headers) {
    if (h.name?.toLowerCase() == 'subject') {
      return h.value ?? '';
    }
  }
  return '';
}

/// Registra tarefa
Future<void> registerEmailCheckTask() async {
  await Workmanager().registerPeriodicTask(
    'emailChecker',
    'emailCheckerTask',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
}

/// Cancela tarefa
Future<void> cancelEmailCheckTask() async {
  await Workmanager().cancelByUniqueName('emailChecker');
}