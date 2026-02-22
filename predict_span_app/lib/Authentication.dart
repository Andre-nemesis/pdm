import 'dart:async';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:http/http.dart' as http;

/// 🔑 COLOQUE AQUI O CLIENT ID WEB
/// ⚠️ NÃO é o client ID Android
/// Exemplo:
/// 1234567890-abcdefg.apps.googleusercontent.com
const String googleWebClientId =
    '70987395511-7rdagq2gjclllaa7sthg1v65e1n54jr5.apps.googleusercontent.com';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: googleWebClientId, // 🔴 AQUI
  scopes: [
    'email',
    'https://www.googleapis.com/auth/gmail.readonly',
  ],
);

GoogleSignInAccount? _currentUser;

/// 🔐 Login manual (UI)
Future<GoogleSignInAccount?> signIn() async {
  try {
    _currentUser = await _googleSignIn.signIn();
    return _currentUser;
  } catch (e) {
    print('❌ Erro no Google Sign-In: $e');
    return null;
  }
}

/// 🔄 Login silencioso (BACKGROUND / WorkManager)
Future<GoogleSignInAccount?> signInSilently() async {
  try {
    _currentUser = await _googleSignIn.signInSilently();
    return _currentUser;
  } catch (e) {
    print('❌ Silent login falhou: $e');
    return null;
  }
}

/// 🚪 Logout
Future<void> signOut() async {
  await _googleSignIn.signOut();
  _currentUser = null;
}

/// 👤 Usuário atual
GoogleSignInAccount? get currentUser => _currentUser;

/// 📬 Cria Gmail API autenticada
Future<GmailApi> getGmailApi(GoogleSignInAccount account) async {
  final authHeaders = await account.authHeaders;
  final client = _AuthenticatedClient(authHeaders);
  return GmailApi(client);
}

/// 📥 Busca emails não lidos
Future<List<Message>> fetchNewEmails(GmailApi gmailApi) async {
  final response = await gmailApi.users.messages.list(
    'me',
    q: 'is:unread',
    labelIds: ['INBOX'],
    maxResults: 10,
  );

  final List<Message> emails = [];

  for (final msg in response.messages ?? []) {
    final full = await gmailApi.users.messages.get('me', msg.id!);
    emails.add(full);
  }

  return emails;
}

/// 📄 Extrai corpo do email
String getEmailBody(Message message) {
  final body = message.payload?.body?.data;
  if (body == null) return '';

  return utf8.decode(
    base64Url.decode(body),
  );
}

/// 🔒 HTTP client autenticado
class _AuthenticatedClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  _AuthenticatedClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}