import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PerfilScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtendo os dados do usuário autenticado
    final User? user = FirebaseAuth.instance.currentUser;

    // Dados fictícios de exemplo para os campos de favoritos, avaliações e comentários
    // Esses dados podem ser atualizados a partir do seu banco de dados conforme necessário
    final int favoritosCount = 10; // Exemplo
    final int avaliacoesCount = 5; // Exemplo
    final int comentariosCount = 20; // Exemplo

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Foto de perfil
              CircleAvatar(
                radius: 80,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(height: 20),

              // Nome do usuário
              Text(
                user?.displayName ?? 'Nome não disponível',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // E-mail do usuário
              Text(
                user?.email ?? 'E-mail não disponível',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),

              // Exibindo estatísticas do usuário
              _buildStatCard('Favoritos', favoritosCount),
              const SizedBox(height: 10),
              _buildStatCard('Avaliações', avaliacoesCount),
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
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
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
              color: Colors.blue,
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
