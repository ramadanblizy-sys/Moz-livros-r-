import 'package:cloud_functions/cloud_functions.dart';

class AdminOrderService {
  AdminOrderService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<void> quoteOrder({
    required String orderId,
    required int deliveryFeeMzn,
  }) async {
    await _functions.httpsCallable('adminQuoteOrder').call({
      'orderId': orderId,
      'deliveryFeeMzn': deliveryFeeMzn,
    });
  }

  Future<void> confirmPayment({
    required String orderId,
    required String providerReference,
  }) async {
    await _functions.httpsCallable('adminConfirmPayment').call({
      'orderId': orderId,
      'providerReference': providerReference,
    });
  }

  Future<void> updateDeliveryStatus({
    required String orderId,
    required String status,
  }) async {
    await _functions.httpsCallable('adminUpdateDeliveryStatus').call({
      'orderId': orderId,
      'status': status,
    });
  }
}
