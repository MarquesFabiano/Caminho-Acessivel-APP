import 'package:firebase_database/firebase_database.dart';

final databaseReference = FirebaseDatabase.instance.ref();

void salvarLugarNoFirebase(String nome, String endereco, double avaliacao, List<String> acessibilidade) {
  String id = databaseReference.child('lugares').push().key!;
  databaseReference.child('lugares/$id').set({
    'nome': nome,
    'endereco': endereco,
    'avaliacao': avaliacao,
    'tiposDeAcessibilidade': acessibilidade,
    'aprovado': true,
  });
}
