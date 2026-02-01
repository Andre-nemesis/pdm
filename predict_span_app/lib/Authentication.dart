import 'dart:async';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:http/http.dart' as http;

Future<GoogleSignInAccount?> signIn() async {
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['https://mail.google.com/']);
  return await googleSignIn.signIn();
}

Future<GoogleSignInAccount?> signInSilently() async {
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['https://mail.google.com/']);
  return await googleSignIn.signInSilently();
}

class AuthenticatedClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner;

  AuthenticatedClient(this._headers, this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}

Future<GmailApi> getGmailApi(GoogleSignInAccount account) async {
  final authHeaders = await account.authHeaders;
  final client = AuthenticatedClient(authHeaders, http.Client());
  return GmailApi(client);
}

Future<List<Message>> fetchNewEmails(GmailApi gmailApi) async {
  final listResponse = await gmailApi.users.messages.list('me', labelIds: ['INBOX'], q: 'is:unread');
  List<Message> messages = [];
  for (var id in listResponse.messages ?? []) {
    final message = await gmailApi.users.messages.get('me', id.id!);
    messages.add(message);
  }
  return messages;
}

String getEmailBody(Message message) {
  final data = message.payload?.body?.data ?? '';
  if (data.isNotEmpty) {
    return String.fromCharCodes(base64Decode(data.replaceAll('-', '+').replaceAll('_', '/')));
  }
  return '';
}