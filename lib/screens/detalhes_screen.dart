import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetalhesLugarScreen extends StatefulWidget {
  final LatLng latLng;
  final String idLugar;

  const DetalhesLugarScreen({Key? key, required this.latLng, required this.idLugar}) : super(key: key);

  @override
  _DetalhesLugarScreenState createState() => _DetalhesLugarScreenState();
}

class _DetalhesLugarScreenState extends State<DetalhesLugarScreen> {
  late TextEditingController _acessibilidadeController;
  late String _acessibilidadeText = '';
  late List<String> _tiposAcessibilidadeSalvos = [];
  bool _isLoading = true;
  bool _isDetalhesSalvos = false;
  String _usuarioQueSalvou = '';
  String _detalhes = '';
  Set<String> _tiposDeAcessibilidade = {
    'Rampas',
    'Piso Tátil',
    'Elevadores',
    'Banheiro Acessível',
    'Vagas de Estacionamento Acessíveis',
    'Sinalização Visual',
    'Sinalização Sonora',
    'Guichê Adaptado',
    'Entrada Larga',
    'Acessibilidade para Deficiência Auditiva',
    'Acessibilidade para Deficiência Visual'
  };

  @override
  void initState() {
    super.initState();
    _acessibilidadeController = TextEditingController();
    _verificarLugarSalvo();
    _obterDetalhesDoLugar();
  }

  Future<void> _verificarLugarSalvo() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot docSnapshot = await firestore.collection('acessibilidade_lugares').doc(widget.idLugar).get();

    if (docSnapshot.exists) {
      setState(() {
        _isDetalhesSalvos = true;
        _usuarioQueSalvou = docSnapshot['usuario_salvou'];
        _tiposAcessibilidadeSalvos = List<String>.from(docSnapshot['tipos_acessibilidade']);
        _detalhes = docSnapshot['detalhes'] ?? '';
      });
    }
  }

  Future<void> _obterDetalhesDoLugar() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot docSnapshot = await firestore.collection('lugares').doc(widget.idLugar).get();

    if (docSnapshot.exists) {
      setState(() {
        _detalhes = docSnapshot['detalhes'] ?? 'Nenhum detalhe encontrado.';
      });

      if (_detalhes == 'Nenhum detalhe encontrado.') {
        await _buscarDetalhesNoGoogle(docSnapshot['nome'], docSnapshot['endereco']);
      }
    }
  }

  Future<void> _buscarDetalhesNoGoogle(String nome, String endereco) async {
    final query = '$nome $endereco';
    final url = Uri.parse('https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=YOUR_GOOGLE_API_KEY');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        setState(() {
          _detalhes = data['results'][0]['formatted_address'] ?? 'Detalhes não encontrados';
        });
      }
    }
  }

  Future<void> _salvarDetalhes() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = 'usuario_logado_id'; // Substitua pelo ID do usuário logado

    await firestore.collection('acessibilidade_lugares').doc(widget.idLugar).set({
      'usuario_salvou': user,
      'tipos_acessibilidade': _tiposDeAcessibilidade.toList(),
      'detalhes': _detalhes,
    });

    setState(() {
      _isDetalhesSalvos = true;
      _usuarioQueSalvou = user;
      _tiposAcessibilidadeSalvos = _tiposDeAcessibilidade.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Lugar'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('Nome do Lugar: ${widget.idLugar}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Detalhes: $_detalhes'),
            const SizedBox(height: 10),
            Text('Tipos de Acessibilidade Salvos:'),
            _tiposAcessibilidadeSalvos.isNotEmpty
                ? Column(
              children: _tiposAcessibilidadeSalvos.map((tipo) => Text(tipo)).toList(),
            )
                : const Text('Nenhum tipo salvo ainda.'),
            const SizedBox(height: 20),
            const Text('Adicionar Novos Tipos de Acessibilidade:'),
            DropdownButtonFormField<String>(
              value: _acessibilidadeText.isNotEmpty ? _acessibilidadeText : null,
              items: _tiposDeAcessibilidade.map((String tipo) {
                return DropdownMenuItem<String>(value: tipo, child: Text(tipo));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _acessibilidadeText = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Escolha o Tipo de Acessibilidade',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (!_tiposDeAcessibilidade.contains(_acessibilidadeText)) {
                    _tiposDeAcessibilidade.add(_acessibilidadeText);
                  }
                });
              },
              child: const Text('Adicionar Tipo'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvarDetalhes,
              child: const Text('Salvar Detalhes e Tipos'),
            ),
          ],
        ),
      ),
    );
  }
}
