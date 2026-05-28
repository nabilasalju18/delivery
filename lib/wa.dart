import 'dart:convert';
import 'package:http/http.dart' as http;

class WhatAppService {
  static Future<void> kirimKeAdmin({
    required String pesanStruk,
  }) async {
    // 1. Pastikan Token dan ID di bawah ini sudah diganti dengan milikmu
    const String botToken = '8697814011:AAF3XsgmGs9-f2oubE_C7ICIBJ225Zz_iL8';
    const String chatIdAdmin = '6138517775';

    final String url = 'https://api.telegram.org/bot$botToken/sendMessage';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': chatIdAdmin,
          'text': pesanStruk, // Mengirim teks polos dulu agar tidak error markdown
        }),
      );

      if (response.statusCode == 200) {
        ('Notifikasi sukses terkirim ke Telegram!');
      } else {
        // Cek pesan error dari Telegram di debug console VS Code kamu
        ('Telegram Gagal: ${response.body}');
      }
    } catch (e) {
      ('Error Network Telegram: $e');
    }
  }
}