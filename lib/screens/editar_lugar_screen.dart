import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class EditarLugarScreen extends StatefulWidget {
  final LatLng latLng;

  const EditarLugarScreen({Key? key, required this.latLng}) : super(key: key);

  @override
  _EditarLugarScreenState createState() => _EditarLugarScreenState();
}

class _EditarLugarScreenState extends State<EditarLugarScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  double _avaliacao = 1.0;
  List<String> _acessibilidade = [];
  String _endereco = '';
  String _usuario = 'Nome do Usuário'; // Defina o nome do usuário aqui

  // Função para obter o endereço com base na latitude e longitude
  Future<void> _obterEndereco() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.latLng.latitude,
        widget.latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        setState(() {
          _endereco = '${placemarks[0].name}, ${placemarks[0].locality}';
        });
      }
    } catch (e) {
      print("Erro ao obter o endereço: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _obterEndereco(); // Obtém o endereço assim que a tela for carregada
  }

  void _salvarLugar() {
    final nome = _nomeController.text;

    if (nome.isNotEmpty && _endereco.isNotEmpty) {
      FirebaseDatabase.instance.ref('lugares').push().set({
        'nome': nome,
        'endereco': _endereco,
        'avaliacao': _avaliacao,
        'tiposDeAcessibilidade': _acessibilidade,
        'latitude': widget.latLng.latitude,
        'longitude': widget.latLng.longitude,
        'aprovado': true,
        'editadoPor': _usuario, // Salvando quem editou
      }).then((_) {
        // Fechar a tela após salvar
        Navigator.pop(context);
      });
    } else {
      // Exibir erro se campos estiverem vazios
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Lugar'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Localização: $_endereco',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Lugar',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Avaliação',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            RatingBar.builder(
              initialRating: _avaliacao,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 40.0,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _avaliacao = rating;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Acessibilidade',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            CheckboxListTile(
              title: const Text('Cadeira de rodas'),
              value: _acessibilidade.contains('Cadeira de rodas'),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _acessibilidade.add('Cadeira de rodas');
                  } else {
                    _acessibilidade.remove('Cadeira de rodas');
                  }
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Banheiro acessível'),
              value: _acessibilidade.contains('Banheiro acessível'),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _acessibilidade.add('Banheiro acessível');
                  } else {
                    _acessibilidade.remove('Banheiro acessível');
                  }
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Entrada acessível'),
              value: _acessibilidade.contains('Entrada acessível'),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _acessibilidade.add('Entrada acessível');
                  } else {
                    _acessibilidade.remove('Entrada acessível');
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvarLugar,
              child: const Text('Salvar Lugar'),
            ),
          ],
        ),
      ),
    );
  }
}
