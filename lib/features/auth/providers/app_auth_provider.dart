import 'package:flutter/material.dart';

import '../../../models/app_user_model.dart';
import '../data/auth_repository.dart';

class AppAuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  AppUserModel? currentUser;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadCurrentUser() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await _repository.getCurrentUserData();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await _repository.signIn(
        email: email,
        password: password,
      );
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerAdmin({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await _repository.registerUser(
        name: name,
        email: email,
        password: password,
        role: 'admin',
      );
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    currentUser = null;
    notifyListeners();
  }
}
