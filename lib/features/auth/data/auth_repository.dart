import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/app_user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<AppUserModel?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return AppUserModel.fromMap(doc.id, doc.data()!);
  }

  Future<AppUserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final uid = credential.user!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      final user = AppUserModel(
        id: uid,
        name: email.split('@').first,
        email: email.trim(),
        role: 'cashier',
      );

      await _firestore.collection('users').doc(uid).set({
        ...user.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    }

    return AppUserModel.fromMap(doc.id, doc.data()!);
  }

  Future<AppUserModel> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = AppUserModel(
      id: credential.user!.uid,
      name: name.trim(),
      email: email.trim(),
      role: role,
    );

    await _firestore.collection('users').doc(user.id).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return user;
  }

  Future<void> signOut() => _auth.signOut();
}
