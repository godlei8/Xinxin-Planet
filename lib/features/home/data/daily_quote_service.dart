import 'dart:convert';

import 'package:http/http.dart' as http;

class DailyQuote {
  const DailyQuote({
    required this.english,
    required this.chinese,
    required this.date,
    required this.imageUrl,
    required this.source,
    this.isFallback = false,
  });

  final String english;
  final String chinese;
  final String date;
  final String imageUrl;
  final String source;
  final bool isFallback;

  factory DailyQuote.fromJson(Map<String, dynamic> json) {
    return DailyQuote(
      english: (json['content'] as String? ?? '').trim(),
      chinese: (json['note'] as String? ?? '').trim(),
      date: (json['dateline'] as String? ?? '').trim(),
      imageUrl: ((json['picture2'] as String?)?.trim().isNotEmpty ?? false)
          ? (json['picture2'] as String).trim()
          : (json['picture'] as String? ?? '').trim(),
      source: (json['caption'] as String? ?? '网络每日一句').trim(),
    );
  }
}

class DailyQuoteService {
  DailyQuoteService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _endpoint = 'https://open.iciba.com/dsapi';

  static const _fallbackQuote = DailyQuote(
    english: 'Tiny progress still counts today.',
    chinese: '今天哪怕只是小小前进，也一样算数。',
    date: '',
    imageUrl: '',
    source: '应用内备用文案',
    isFallback: true,
  );

  Future<DailyQuote> fetchTodayQuote() async {
    try {
      final uri = Uri.parse(_endpoint).replace(
        queryParameters: {
          '_t': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return _fallbackQuote;
      }

      final decoded = jsonDecode(
        utf8.decode(response.bodyBytes),
      ) as Map<String, dynamic>;
      final quote = DailyQuote.fromJson(decoded);

      if (quote.english.isEmpty || quote.chinese.isEmpty) {
        return _fallbackQuote;
      }

      return quote;
    } catch (_) {
      return _fallbackQuote;
    }
  }
}
