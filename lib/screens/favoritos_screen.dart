import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/lugar.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'perfil_screen.dart';
import 'busca_lugares_screen.dart';
import '../widgets/bottom_navigation_bar.dart';

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
        backgroundColor: Colors.blue.shade700,
        title: const Text('Favoritos', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream:
            FirebaseDatabase.instance.ref('users/$userId/favoritos').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(child: Text('Nenhum favorito encontrado.'));
          }

          // Verifique se o valor é realmente um mapa
          final favoritosMap = snapshot.data!.snapshot.value;
          List<dynamic> favoritos = [];

          // Se for um mapa (como esperado do Firebase), converta para uma lista
          if (favoritosMap is Map) {
            favoritos = favoritosMap.keys
                .toList(); // Obtém as chaves (IDs dos lugares favoritos)
          }

          return StreamBuilder(
            stream: FirebaseDatabase.instance.ref('lugares').onValue,
            builder: (context, lugaresSnapshot) {
              if (lugaresSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!lugaresSnapshot.hasData ||
                  lugaresSnapshot.data!.snapshot.value == null) {
                return Center(child: Text('Nenhum lugar encontrado.'));
              }

              List<dynamic> lugares = [];
              final lugaresMap = lugaresSnapshot.data!.snapshot.value;

              // Verifique se o valor é um mapa (como esperado do Firebase)
              if (lugaresMap is Map) {
                lugares = lugaresMap.values
                    .toList(); // Obtém os valores (dados dos lugares)
              }

              // Filtrar os lugares que estão nos favoritos
              List<Lugar> lugaresFavoritos = lugares
                  .where((lugar) => favoritos.contains(lugar['id']))
                  .map((lugar) =>
                      Lugar.fromMap(Map<String, dynamic>.from(lugar)))
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
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 3, // Ajuste conforme necessário
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/editar');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/perfil');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/favoritos');
          }
        },
      ),
    );
  }
}
