// local_notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;

  /// Inicializa o serviço de notificações
  /// Deve ser chamado no main() ou antes de usar
  static Future<void> initialize() async {
    if (_initialized) return;

    // Inicializar timezone para notificações agendadas
    tz.initializeTimeZones();

    // Configurações para Android
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configurações para iOS - usa DarwinInitializationSettings (versão mais recente)
    // ou IOSInitializationSettings (versão antiga)
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Configurações gerais
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Inicializar
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    print('✅ Serviço de notificações locais inicializado');
  }

  /// Callback quando notificação é tocada
  static void _onNotificationTapped(NotificationResponse response) {
    print('Notificação tocada: ${response.payload}');
    // TODO: Navegar para tela específica se necessário
    // Ex: Navigator.push(...) para mostrar detalhes do email spam
  }

  /// Solicita permissões de notificação (necessário para Android 13+)
  static Future<bool> requestPermissions() async {
    bool? granted;

    // Android
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      granted = await androidPlugin.requestNotificationsPermission();
      if (granted != true) return false;
    }

    // iOS / macOS
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Envia uma notificação simples
  /// 
  /// Parâmetros:
  ///   - id: ID único da notificação
  ///   - title: Título da notificação
  ///   - body: Corpo da notificação
  ///   - payload: Dados extras (opcional)
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = 
        AndroidNotificationDetails(
      'spam_channel', // ID do canal
      'Detecção de Spam', // Nome do canal
      channelDescription: 'Notificações de emails spam detectados',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFE53935), // Vermelho para indicar spam
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );

    print('📬 Notificação enviada: $title');
  }

  /// Envia notificação de spam detectado
  static Future<void> showSpamNotification({
    required String emailSubject,
    required String emailSnippet,
    required String emailId,
  }) async {
    await showNotification(
      id: emailId.hashCode, // Usa hash do ID como identificador único
      title: '⚠️ Spam Detectado',
      body: emailSubject.isNotEmpty 
          ? 'De: $emailSubject'
          : emailSnippet.substring(0, emailSnippet.length > 50 ? 50 : emailSnippet.length),
      payload: emailId, // Pode ser usado para abrir o email específico
    );
  }

  /// Envia notificação de resumo (múltiplos spams)
  static Future<void> showSpamSummaryNotification({
    required int spamCount,
  }) async {
    await showNotification(
      id: 999999, // ID fixo para resumo
      title: '⚠️ $spamCount ${spamCount == 1 ? "Spam Detectado" : "Spams Detectados"}',
      body: 'Toque para ver os detalhes',
      payload: 'spam_summary',
    );
  }

  /// Envia notificação agendada
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = 
        AndroidNotificationDetails(
      'spam_channel',
      'Detecção de Spam',
      channelDescription: 'Notificações de emails spam detectados',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Cancela uma notificação específica
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancela todas as notificações
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Obtém notificações pendentes
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Obtém notificações ativas
  static Future<List<ActiveNotification>> getActiveNotifications() async {
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      return await androidImplementation.getActiveNotifications();
    }
    
    return [];
  }
}
