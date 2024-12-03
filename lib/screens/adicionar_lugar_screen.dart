import 'package:flutter/material.dart';
import 'package:terca/utils/acessibilidade_types.dart'; // Seu arquivo de tipos de acessibilidade

class AdicionarLugarScreen extends StatefulWidget {
  @override
  _AdicionarLugarScreenState createState() => _AdicionarLugarScreenState();
}

class _AdicionarLugarScreenState extends State<AdicionarLugarScreen> {
  String? _selectedAcessibilidade;
  double _avaliacao = 0.0;
  final _nomeController = TextEditingController();
  final _enderecoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Lugar Acessível')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome do Lugar'),
            ),
            TextField(
              controller: _enderecoController,
              decoration: InputDecoration(labelText: 'Endereço'),
            ),
            DropdownButton<String>(
              value: _selectedAcessibilidade,
              hint: Text('Selecione o Tipo de Acessibilidade'),
              onChanged: (value) {
                setState(() {
                  _selectedAcessibilidade = value;
                });
              },
              items: AcessibilidadeTypes.labels.values.map((label) {
                return DropdownMenuItem<String>(
                  value: label,
                  child: Text(label),
                );
              }).toList(),
            ),
            Slider(
              value: _avaliacao,
              min: 1.0,
              max: 5.0,
              divisions: 4,
              label: _avaliacao.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _avaliacao = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                // Adicionar o lugar ao Firebase
                // Firebase logic to save the place info
              },
              child: Text('Adicionar Lugar'),
            ),
          ],
        ),
      ),
    );
  }
}
