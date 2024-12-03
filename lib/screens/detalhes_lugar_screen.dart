import 'package:flutter/material.dart';

class DetalhesLugarScreen extends StatelessWidget {
  final String nome;
  final String endereco;
  final double avaliacao;
  final List<String> acessibilidade;

  DetalhesLugarScreen({
    required this.nome,
    required this.endereco,
    required this.avaliacao,
    required this.acessibilidade,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(nome)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Endereço: $endereco', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Avaliação: ${avaliacao.toStringAsFixed(1)} estrelas', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Tipos de Acessibilidade:', style: TextStyle(fontSize: 16)),
            for (var tipo in acessibilidade)
              Text('- $tipo', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
