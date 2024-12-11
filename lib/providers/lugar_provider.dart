import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/lugar.dart';

class LugarProvider with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Stream<List<Lugar>> buscarLugaresStream(
      String termoDeBusca, String localizacao) {
    return _database
        .child('lugares')
        .orderByChild('name')
        .startAt(termoDeBusca)
        .endAt(termoDeBusca + '\uf8ff')
        .onValue
        .map((event) {
      List<Lugar> lugares = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> lugaresMap =
        event.snapshot.value as Map<dynamic, dynamic>;
        lugaresMap.forEach((key, value) {
          Lugar lugar = Lugar.fromMap(Map<String, dynamic>.from(value));
          lugares.add(lugar);
        });
      }
      return lugares;
    });
  }

  Future<void> aprovarLugar(String lugarId) async {
    try {
      await _database.child('lugares').child(lugarId).update({'aprovado': true});
    } catch (e) {
      throw Exception('Erro ao aprovar lugar: $e');
    }
  }

  Future<void> avaliarLugar(String lugarId, double nota) async {
    try {
      await _database.child('lugares').child(lugarId).update({
        'avaliacao': nota,
      });
    } catch (e) {
      throw Exception('Erro ao avaliar lugar: $e');
    }
  }

  Future<void> editarLugar(String lugarId, Lugar novosDados) async {
    try {
      await _database
          .child('lugares')
          .child(lugarId)
          .update(novosDados.toMap());
    } catch (e) {
      throw Exception('Erro ao editar lugar: $e');
    }
  }

  Future<void> favoritarLugar(Lugar lugar) async {
    try {
      final favoritoRef = _database.child('favoritos').child(lugar.id);
      await favoritoRef.set(lugar.toMap());
    } catch (e) {
      throw Exception('Erro ao adicionar lugar aos favoritos: $e');
    }
  }

  Future<void> removerFavorito(Lugar lugar) async {
    try {
      await _database.child('favoritos').child(lugar.id).remove();
    } catch (e) {
      throw Exception('Erro ao remover lugar dos favoritos: $e');
    }
  }

  Stream<List<Lugar>> buscarFavoritosStream() {
    return _database.child('favoritos').onValue.map((event) {
      List<Lugar> lugares = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> favoritosMap =
        event.snapshot.value as Map<dynamic, dynamic>;
        favoritosMap.forEach((key, value) {
          Lugar lugar = Lugar.fromMap(Map<String, dynamic>.from(value));
          lugares.add(lugar);
        });
      }
      return lugares;
    });
  }

  Future<void> adicionarComentario(String lugarId, String comentario) async {
    try {
      await _database.child('lugares').child(lugarId).update({
        'comentarios': comentario,
      });
    } catch (e) {
      throw Exception('Erro ao adicionar comentário: $e');
    }
  }

  // Nova função para buscar detalhes de um lugar específico
  Future<Lugar?> buscarDetalhesLugar(String lugarId) async {
    try {
      final snapshot = await _database.child('lugares').child(lugarId).get();
      if (snapshot.value != null) {
        return Lugar.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar detalhes do lugar: $e');
    }
  }
}
