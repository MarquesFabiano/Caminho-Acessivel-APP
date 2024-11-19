import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/lugar.dart';

class LugarProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Lugar>> buscarLugares(String termoDeBusca, String localizacao) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('lugares')
          .where('name', isGreaterThanOrEqualTo: termoDeBusca)
          .where('formattedAddress', isGreaterThanOrEqualTo: localizacao)
          .get();

      return snapshot.docs.map((doc) {
        return Lugar.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar lugares: $e');
    }
  }

  Future<void> aprovarLugar(String lugarId) async {
    try {
      await _firestore.collection('lugares').doc(lugarId).update({'aprovado': true});
    } catch (e) {
      throw Exception('Erro ao aprovar lugar: $e');
    }
  }

  Future<void> avaliarLugar(String lugarId, double nota) async {
    try {
      await _firestore.collection('lugares').doc(lugarId).update({
        'avaliacao': nota,
      });
    } catch (e) {
      throw Exception('Erro ao avaliar lugar: $e');
    }
  }

  Future<void> editarLugar(String lugarId, Lugar novosDados) async {
    try {
      await _firestore.collection('lugares').doc(lugarId).update(novosDados.toMap());
    } catch (e) {
      throw Exception('Erro ao editar lugar: $e');
    }
  }
}
