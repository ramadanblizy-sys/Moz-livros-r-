import 'package:cloud_functions/cloud_functions.dart';

class DigitalBookService {
  DigitalBookService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<DigitalBookAccess> requestAccess(String orderId) async {
    final result = await _functions
        .httpsCallable('getDigitalBookDownloadUrl')
        .call({'orderId': orderId});
    final data = Map<String, dynamic>.from(result.data as Map);
    final url = data['url'];
    if (url is! String || url.isEmpty) {
      throw StateError('O servidor não devolveu um endereço válido para o livro.');
    }
    return DigitalBookAccess(
      url: url,
      title: (data['title'] ?? 'Livro digital').toString(),
      expiresInSeconds: (data['expiresInSeconds'] as num?)?.toInt() ?? 300,
    );
  }
}

class DigitalBookAccess {
  const DigitalBookAccess({
    required this.url,
    required this.title,
    required this.expiresInSeconds,
  });

  final String url;
  final String title;
  final int expiresInSeconds;
}
