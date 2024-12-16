import 'package:flutter/material.dart';

class DetalhesLugarScreen extends StatelessWidget {
  final String nome;
  final String endereco;
  final double avaliacao;
  final List<String> acessibilidade;
  final String telefone;
  final String website;

  DetalhesLugarScreen({
    required this.nome,
    required this.endereco,
    required this.avaliacao,
    required this.acessibilidade,
    required this.telefone,
    required this.website,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nome),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              endereco,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            '${avaliacao.toStringAsFixed(1)} estrelas',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.blueAccent),
                          SizedBox(width: 8),
                          Text(
                            telefone,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.web, color: Colors.green),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              // Abre o site no navegador
                              // launchUrl(Uri.parse(website));
                            },
                            child: Text(
                              website,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Tipos de Acessibilidade:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: acessibilidade
                    .map((tipo) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tipo,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
