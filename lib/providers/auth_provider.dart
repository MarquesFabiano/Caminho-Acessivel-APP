import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  User? get user => _user;

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _user = _auth.currentUser;
      notifyListeners();
    } catch (e) {
      throw Exception('Falha ao fazer login: $e');
    }
  }

  Future<void> cadastrarUsuario(String name, String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _user = _auth.currentUser;
      notifyListeners();
    } catch (e) {
      throw Exception('Falha ao cadastrar usuário: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
