import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/lugar.dart';

class LugarProvider with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Função para buscar lugares com base no termo de busca e localização
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

  // Função de aprovar lugar
  Future<void> aprovarLugar(String lugarId) async {
    try {
      await _database
          .child('lugares')
          .child(lugarId)
          .update({'aprovado': true});
    } catch (e) {
      throw Exception('Erro ao aprovar lugar: $e');
    }
  }

  // Função de avaliar lugar
  Future<void> avaliarLugar(String lugarId, double nota) async {
    try {
      await _database.child('lugares').child(lugarId).update({
        'avaliacao': nota,
      });
    } catch (e) {
      throw Exception('Erro ao avaliar lugar: $e');
    }
  }

  // Função de editar lugar
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

  // Função para adicionar lugar aos favoritos
  Future<void> favoritarLugar(Lugar lugar) async {
    try {
      final favoritoRef = _database.child('favoritos').child(lugar.id);
      await favoritoRef.set(lugar.toMap());
    } catch (e) {
      throw Exception('Erro ao adicionar lugar aos favoritos: $e');
    }
  }

  // Função para remover lugar dos favoritos
  Future<void> removerFavorito(Lugar lugar) async {
    try {
      await _database.child('favoritos').child(lugar.id).remove();
    } catch (e) {
      throw Exception('Erro ao remover lugar dos favoritos: $e');
    }
  }

  // Função para buscar favoritos
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
}
