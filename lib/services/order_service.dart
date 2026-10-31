import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> createOrder({
    required String bookId,
    required String bookTitle,
    required String format,
    required int bookPriceMzn,
    required String paymentMethod,
    required String deliveryType,
    required String customerPhone,
    String? deliveryAddress,
    String? pickupPoint,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Inicie sessão antes de fazer uma encomenda.');

    final isPhysical = format == 'Físico' || format == 'PDF e físico';
    final isHomeDelivery = isPhysical && deliveryType == 'Entrega ao domicílio';

    final ref = await _db.collection('orders').add({
      'customerUid': user.uid,
      'customerEmail': user.email,
      'customerPhone': customerPhone.trim(),
      'bookId': bookId,
      'bookTitle': bookTitle,
      'format': format,
      'bookPriceMzn': bookPriceMzn,
      'paymentMethod': paymentMethod,
      'deliveryType': isPhysical ? deliveryType : 'Não aplicável',
      'deliveryAddress': isHomeDelivery ? deliveryAddress?.trim() : null,
      'pickupPoint': isPhysical && deliveryType == 'Levantamento' ? pickupPoint : null,
      // A taxa de entrega ao domicílio será calculada/confirmada pelo administrador.
      'deliveryFeeMzn': isHomeDelivery ? null : 0,
      'totalMzn': isHomeDelivery ? null : bookPriceMzn,
      'deliveryFeeStatus': isHomeDelivery ? 'quote_pending' : 'not_applicable',
      'status': 'pending',
      'paymentStatus': 'awaiting_payment',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> customerOrders() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Sessão não iniciada.');
    return _db.collection('orders')
        .where('customerUid', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
