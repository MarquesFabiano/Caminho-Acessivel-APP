import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/lugar.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Verifica se o usuário está autenticado
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Favoritos'),
        ),
        body: Center(
          child: Text('Você precisa estar logado para ver seus favoritos.'),
        ),
      );
    }

    final userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref('users/$userId/favoritos').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(child: Text('Nenhum favorito encontrado.'));
          }

          List<dynamic> favoritos = snapshot.data!.snapshot.value as List<dynamic>;
          favoritos = favoritos.where((id) => id != null).toList(); // Remove valores nulos

          return StreamBuilder(
            stream: FirebaseDatabase.instance.ref('lugares').onValue,
            builder: (context, lugaresSnapshot) {
              if (lugaresSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!lugaresSnapshot.hasData || lugaresSnapshot.data!.snapshot.value == null) {
                return Center(child: Text('Nenhum lugar encontrado.'));
              }

              List<dynamic> lugares = lugaresSnapshot.data!.snapshot.value as List<dynamic>;
              lugares = lugares.where((lugar) => lugar != null).toList(); // Remove valores nulos

              // Filtrar os lugares que estão nos favoritos
              List<Lugar> lugaresFavoritos = lugares
                  .where((lugar) => favoritos.contains(lugar['id']))
                  .map((lugar) => Lugar.fromMap(Map<String, dynamic>.from(lugar)))
                  .toList();

              if (lugaresFavoritos.isEmpty) {
                return Center(child: Text('Nenhum favorito encontrado.'));
              }

              return ListView.builder(
                itemCount: lugaresFavoritos.length,
                itemBuilder: (context, index) {
                  final lugar = lugaresFavoritos[index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(lugar.name),
                      subtitle: Text(lugar.formattedAddress),
                      trailing: Text('${lugar.avaliacao} ★'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
