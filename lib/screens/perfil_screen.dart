import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart'; // Importando o widget

class PerfilScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
          backgroundColor: Colors.blue, // Cor mais condizente com o tema
        ),
        body: const Center(
          child: Text('Usuário não autenticado.'),
        ),
      );
    }

    final userId = user.uid;
    final userRef = FirebaseDatabase.instance.ref('users/$userId');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        backgroundColor: Colors.blue, // Cor consistente
      ),
      body: StreamBuilder(
        stream: userRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: Text('Dados do usuário não encontrados.'));
          }

          final userData = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

          final favoritosCount = (userData['favoritos'] as List?)?.length ?? 0;
          final comentariosCount = (userData['comentarios'] as List?)?.length ?? 0;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Foto de perfil
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(height: 20),

                  // Nome do usuário
                  Text(
                    userData['name'] ?? 'Nome não disponível',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // E-mail do usuário
                  Text(
                    userData['email'] ?? 'E-mail não disponível',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Exibindo estatísticas do usuário
                  _buildStatCard('Favoritos', favoritosCount),
                  const SizedBox(height: 10),
                  _buildStatCard('Comentários', comentariosCount),
                  const SizedBox(height: 30),

                  // Botão de logout
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Sair'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Substituindo 'primary' por 'backgroundColor'
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2, // Índice para a tela de perfil
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

  // Função para criar cards com as estatísticas do usuário
  Widget _buildStatCard(String title, int count) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border, // Ícone genérico, pode ser alterado conforme o contexto
              size: 30,
              color: Colors.blue, // Cor para combinar com o design
            ),
            const SizedBox(width: 10),
            Text(
              '$title: $count',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
