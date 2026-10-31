import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authChanges => _auth.authStateChanges();

  Future<void> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user!.updateDisplayName(name.trim());
    await _db.collection('users').doc(credential.user!.uid).set({
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'role': 'customer',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();

  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    // A função administrativa depende de uma custom claim definida no servidor.
    final token = await user.getIdTokenResult(true);
    return token.claims?['admin'] == true;
  }
}

class BookRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchPublishedBooks() {
    return _db.collection('books')
        .where('published', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addBook({
    required String title,
    required String author,
    required String genre,
    required String format,
    required int priceMzn,
    String? coverUrl,
    String? pdfPath,
  }) async {
    await _db.collection('books').add({
      'title': title.trim(),
      'author': author.trim(),
      'genre': genre.trim(),
      'format': format,
      'priceMzn': priceMzn,
      'coverUrl': coverUrl,
      'pdfPath': pdfPath,
      'published': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBook(String id, Map<String, dynamic> data) async {
    await _db.collection('books').doc(id).update(data);
  }

  Future<void> deleteBook(String id) async {
    await _db.collection('books').doc(id).delete();
  }
}
