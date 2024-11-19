import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // Adicionando o Firebase Realtime Database
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref(); // Referência ao Realtime Database

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
      // Criação do usuário no Firebase Auth
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _user = _auth.currentUser;

      // Adicionando o usuário no Firebase Realtime Database
      if (_user != null) {
        await _database.child('users').child(_user!.uid).set({
          'id': _user!.uid,
          'name': name,
          'email': email,
          'isAdmin': false,
          'favoritos': [],
          'comentarios': [],
        });
      }

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
