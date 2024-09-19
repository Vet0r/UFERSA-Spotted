import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

Future<void> sendPushNotification(
    String token, String title, String body) async {
  String projName = FirebaseMessaging.instance.app.name;
  String fcmUrl =
      'https://fcm.googleapis.com/v1/projects/$projName/messages:send';
  String? serverKey =
      '977398905790-jh57gg77ajlukuusfqufjnn94sd8cbr7.apps.googleusercontent.com';
  try {
    // Cria o corpo da requisição com a notificação
    final message = {
      'to': token, // Token do dispositivo
      'notification': {
        'title': title, // Título da notificação
        'body': body, // Corpo da notificação
        'sound': 'default' // Som da notificação
      },
      'data': {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK', // Ação personalizada
        'status': 'done', // Dados adicionais
      }
    };

    // Faz a requisição HTTP POST para o FCM
    final response = await http.post(
      Uri.parse(fcmUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey', // Adiciona a Server Key no cabeçalho
      },
      body: jsonEncode(message), // Converte a mensagem para JSON
    );

    if (response.statusCode == 200) {
      print('Notificação enviada com sucesso!');
    } else {
      print('Falha ao enviar notificação. Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('Erro ao enviar notificação: $e');
  }
}
