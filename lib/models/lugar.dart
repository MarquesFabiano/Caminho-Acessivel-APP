import 'package:cloud_firestore/cloud_firestore.dart';

class Lugar {
  final String id;
  final String name;
  final String formattedAddress;
  final List<String> tiposDeAcessibilidade;
  final bool aprovado;
  final double avaliacao;
  String comentarios; // Novo campo para comentários

  Lugar({
    required this.id,
    required this.name,
    required this.formattedAddress,
    required this.tiposDeAcessibilidade,
    required this.aprovado,
    required this.avaliacao,
    this.comentarios = '', // Campo de comentários com valor padrão
  });

  // Criando um Lugar a partir de um Map do Firestore
  factory Lugar.fromMap(Map<String, dynamic> map) {
    return Lugar(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      formattedAddress: map['formattedAddress'] ?? '',
      tiposDeAcessibilidade: List<String>.from(map['tiposDeAcessibilidade'] ?? []),
      aprovado: map['aprovado'] ?? false,
      avaliacao: map['avaliacao'] ?? 0.0,
      comentarios: map['comentarios'] ?? '', // Novo campo para comentários
    );
  }

  // Convertendo o objeto Lugar para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'formattedAddress': formattedAddress,
      'tiposDeAcessibilidade': tiposDeAcessibilidade,
      'aprovado': aprovado,
      'avaliacao': avaliacao,
      'comentarios': comentarios, // Incluir comentários ao salvar
    };
  }

  // Função para salvar o Lugar no Firebase
  Future<void> salvarLugar() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Verificando se já existe um lugar com o mesmo ID, se sim, atualizando
      DocumentReference lugarRef = firestore.collection('lugares').doc(id);
      await lugarRef.set(toMap(), SetOptions(merge: true)); // merge para atualizar sem sobrescrever
    } catch (e) {
      print('Erro ao salvar lugar: $e');
    }
  }

  // Função para buscar todos os lugares no Firebase
  static Future<List<Lugar>> buscarLugares() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Lugar> lugares = [];

    try {
      QuerySnapshot snapshot = await firestore.collection('lugares').get();
      for (var doc in snapshot.docs) {
        lugares.add(Lugar.fromMap(doc.data() as Map<String, dynamic>));
      }
    } catch (e) {
      print('Erro ao buscar lugares: $e');
    }

    return lugares;
  }
}
