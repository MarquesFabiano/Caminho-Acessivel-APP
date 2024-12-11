import 'package:firebase_database/firebase_database.dart';

class Lugar {
  final String id;
  final String name;
  final String formattedAddress;
  final List<String> tiposDeAcessibilidade;
  final bool aprovado;
  final double avaliacao;
  String comentarios;
  final double latitude;
  final double longitude;
  final String icone;

  Lugar({
    required this.id,
    required this.name,
    required this.formattedAddress,
    required this.tiposDeAcessibilidade,
    required this.aprovado,
    required this.avaliacao,
    this.comentarios = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.icone = '',
  });

  factory Lugar.fromMap(Map<String, dynamic> map) {
    return Lugar(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      formattedAddress: map['formattedAddress'] ?? '',
      tiposDeAcessibilidade: List<String>.from(map['tiposDeAcessibilidade'] ?? []),
      aprovado: map['aprovado'] ?? false,
      avaliacao: map['avaliacao']?.toDouble() ?? 0.0,
      comentarios: map['comentarios'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      icone: map['icone'] ?? '',
    );
  }

  // Para buscar lugares no Realtime Database
  static Future<List<Lugar>> buscarLugares() async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    List<Lugar> lugares = [];
    try {
      DatabaseReference ref = database.ref('lugares');
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> lugaresMap = snapshot.value as Map<dynamic, dynamic>;

        lugaresMap.forEach((key, value) {
          lugares.add(Lugar.fromMap(Map<String, dynamic>.from(value)));
        });
      }
    } catch (e) {
      print('Erro ao buscar lugares: $e');
    }
    return lugares;
  }

  // Salvando um lugar
  Future<void> salvarLugar() async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    try {
      DatabaseReference lugarRef = database.ref('lugares').child(id);
      await lugarRef.set(toMap());
    } catch (e) {
      print('Erro ao salvar lugar: $e');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'formattedAddress': formattedAddress,
      'tiposDeAcessibilidade': tiposDeAcessibilidade,
      'aprovado': aprovado,
      'avaliacao': avaliacao,
      'comentarios': comentarios,
      'latitude': latitude,
      'longitude': longitude,
      'icone': icone,
    };
  }
}
