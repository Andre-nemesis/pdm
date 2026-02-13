// main.dart
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:predict_span_app/BackgroundService.dart';
import 'package:predict_span_app/local_notification_service.dart';

// Importar todas as telas
import 'screens/splash_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/login_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/result_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar WorkManager
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  
  // Inicializar serviço de notificações locais
  await LocalNotificationService.initialize();
  
  // Solicitar permissões de notificação
  await LocalNotificationService.requestPermissions();
  
  // TODO: Descomentar após configurar Firebase (se necessário)
  // import 'package:firebase_core/firebase_core.dart';
  // import 'firebase_options.dart';
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartText IA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4285F4),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      // Define a splash screen como tela inicial
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/intro': (context) => const IntroScreen(),
        '/login': (context) => const LoginScreen(),
        '/analysis': (context) => const AnalysisScreen(),
      },
      // Para rotas com parâmetros (como a tela de resultado)
      onGenerateRoute: (settings) {
        if (settings.name == '/result') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ResultScreen(
              text: args['text'] as String,
              isSpam: args['isSpam'] as bool,
            ),
          );
        }
        return null;
      },
    );
  }
}
